#pragma once
#include "basic/detector_basic.h"
#include "canny.h"
#include "contour.h"
#include <iostream>
#include <algorithm>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "basic/stb_image_write.h"

class CSSDetector : public Detector {
public:
    double th_low;
    double th_high;

    CSSDetector(double th_low, double th_high) :
        th_low(th_low), th_high(th_high) {}

    int detect(const Img &gray, std::vector <KeyPoint> *keypoints) {
        static int dx[8] = {1, 1, 0, -1, -1, -1, 0, 1};
        static int dy[8] = {0, 1, 1,  1,  0, -1,-1,-1};

        int gauss_size = 5;

        int width = gray.width;
        int height = gray.height;

        // smooth
        // a non-trival kernel will produce double edges and CSS corners may be duplicated

        Img smooth = gaussian<unsigned char>(gray, gauss_size, gauss_size, 1.4);

        // extract edges
        Img isEdge = canny(smooth, th_low, th_high, L1, SOBEL);
        smooth.release();

        // find contours
        std::vector<Contour> contours = findContours(isEdge);

        // for visualization
        
        /*
        Img ctrs(width, height);
        for (int y = 0; y < height; ++y)
            for (int x = 0; x < width; ++x)
                ctrs(x, y) = 0;
        for (int i = 0; i < contours.size(); ++i) {
            for (int j = 0; j < contours[i].size(); ++j) {
                ctrs(contours[i].x(j), contours[i].y(j)) = 255;
            }
        }
        for (int i = 0; i < contours.size(); ++i) {
            if (contours[i].type != CLOSED)
                continue;
            Img temp(width, height);
            for (int y = 0; y < height; ++y)
                for (int x = 0; x < width; ++x)
                    temp(x, y) = 0;
            for (int j = 0; j < contours[i].size(); ++j) {
                temp(contours[i].x(j), contours[i].y(j)) = 255;
            }
            char bmpname[50];
            sprintf(bmpname, "canny%d.bmp", i);
            stbi_write_bmp(bmpname, width, height, 1, temp.data);  
            temp.release();          
        }
        stbi_write_bmp("canny_ctrs.bmp", width, height, 1, ctrs.data);
        stbi_write_bmp("canny.bmp", width, height, 1, isEdge.data);
        */
        
        // find T corners
        std::vector<KeyPoint> Tcorners = findTcorners(isEdge, contours);
        std::vector<KeyPoint> CSScorners; CSScorners.clear();

        /*
        Img temp(width, height, 3);
        for (int y = 0; y < height; ++y)
            for (int x = 0; x < width; ++x)
                temp(x, y, 0) = temp(x, y, 1) = temp(x, y, 2) = gray(x, y);
        for (int i = 0; i < Tcorners.size(); ++i) {
            mark_keypoint_with_r3(temp, Tcorners[i], GREEN);
        }
        temp.release();
        stbi_write_bmp("Tcorners.bmp", width, height, 3, temp.data); 
        */

        // preparation for the CSS
        double sigma[4] = {4, 2, 1, 0.7};
        int n[4] = {25, 13, 7, 5};

        Matrix3D<double> *ker_g[4];
        Matrix3D<double> *ker_gg[4];

        for (int i = 0; i < 4; ++i) {
            Matrix3D<double> ker = get_gaussian_ker(n[i], 1, sigma[i]);
            ker_g[i] = new Matrix3D<double>(n[i]+2, 1);
            ker_gg[i] = new Matrix3D<double>(n[i]+4, 1);
            for (int j = 0; j < n[i]+2; ++j) {
                if (j == 0)
                    ker_g[i]->at(j, 0) = 0;
                else {
                    double a = j == n[i]+1 ? 0 : ker(j-1, 0);
                    double b = j == 1 ? 0 : ker(j-2, 0);
                    ker_g[i]->at(j, 0) = a - b;
                }
            }
            for (int j = 0; j < n[i]+4; ++j) {
                if (j == n[i]+3) 
                    ker_gg[i]->at(j, 0) = 0;
                else {
                    double a = j == n[i]+2 ? 0 : ker_g[i]->at(j, 0);
                    double b = j == 0 ? 0 : ker_g[i]->at(j-1, 0);
                    ker_gg[i]->at(j, 0) = a - b;
                }
            }
        }

        // CSS process
        double threshold = 0.03;
        std::vector<int> alters;
        for (int i = 0; i < contours.size(); ++i) {
            Contour ct = contours[i];
            BorderType border_type = ct.type == CLOSED ? CYCLE : REPLICATE;
            int m = ct.size();
            alters.clear();
            Matrix3D<double> seq(m, 1, 2);
            for (int j = 0; j < m; ++j) {
                seq(j, 0, 0) = ct.x(j);
                seq(j, 0, 1) = ct.y(j);
            }
            int offset = m;
            int bound  = 3*m;
            double *ker = new double[bound];
            for (int k = 0; k < bound; ++k)
                ker[k] = 1;

            for (int j = 0; j < 4; ++j) {
                auto g  = filter2D<double>(seq, *ker_g[j],  border_type);
                auto gg = filter2D<double>(seq, *ker_gg[j], border_type);
                for (int k = 0; k < m; ++k) {
                    ker[k+m] = fabs(g(k,0,0)*gg(k,0,1) - g(k,0,1)*gg(k,0,0)) / 
                               pow(g(k,0,0)*g(k,0,0) + g(k,0,1)*g(k,0,1), 1.5);
                    if (border_type == CYCLE)
                        ker[k] = ker[k+m+m] = ker[k+m];
                }
                int mpos = -1;
                double minima = 1;
                if (j == 0) {
                    for (int k = bound-2; k >= 1; --k) {
                        int p = k-1, q = k+1;
                        if (ker[k] > ker[p] && ker[k] >= ker[q]) {
                            if (ker[k] > minima * 2)
                                mpos = k;
                            else mpos = -1;
                        }
                        if (ker[k] < ker[p] && ker[k] <= ker[q]) {
                            if (mpos != -1 && ker[mpos] > ker[k] * 2) {
                                if (ker[mpos] >= threshold && 
                                    mpos >= m && mpos < (m<<1))
                                    alters.push_back(mpos-offset);
                            }
                            else mpos = -1;
                            minima = ker[k];
                        }
                    }
                }
                else {
                    for (int k = 0; k < alters.size(); ++k) {
                        int pos = alters[k]+offset;
                        for (int p = -3; p <= 3; ++p) {
                            int np = pos+p;
                            if (np >= 0 && np < m && ker[np] >= ker[pos])
                                pos = np;
                        }
                        alters[k] = pos % m;
                    }
                }
                g.release();
                gg.release();
            }
            delete ker;
            seq.release();

            for (int k = 0; k < alters.size(); ++k) {
                int pos = alters[k];
                CSScorners.push_back(KeyPoint(ct.x(pos), ct.y(pos)));
            }
            ct.release();
        }

        // remove duplicated CSS corners produced by blurring
        for (int i = 0; i < CSScorners.size(); ++i) {
            KeyPoint pi = CSScorners[i];

            bool removed = false;
            for (int j = i + 1; j < CSScorners.size(); ++j) {
                KeyPoint pj = CSScorners[j];
                if (std::max(abs(pi.x-pj.x), abs(pi.y-pj.y)) <= 6) {
                    removed = true;
                    break;
                }
            }
            if (removed == false)
                keypoints->push_back(CSScorners[i]);
        }


        // remove duplicated T corners
        for (int i = 0; i < Tcorners.size(); ++i) {
            KeyPoint pi = Tcorners[i];

            bool removed = false;
            for (int j = 0; j < keypoints->size(); ++j) {
                KeyPoint pj = keypoints->at(j);
                if (std::max(abs(pi.x-pj.x), abs(pi.y-pj.y)) <= 6) {
                    removed = true;
                    break;
                }
            }
            if (removed == false)
                keypoints->push_back(Tcorners[i]);
        }

        Tcorners.clear();
        Tcorners.shrink_to_fit();
        CSScorners.clear();
        CSScorners.shrink_to_fit();
        for (int i = 0; i < 4; ++i) {
            ker_g[i]->release();
            ker_gg[i]->release();
        }
        isEdge.release();

        return keypoints->size();
    }
};
