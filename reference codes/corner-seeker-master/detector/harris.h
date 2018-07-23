#pragma once
#include "basic/detector_basic.h"

enum HarrisScoreType {
    HARRIS, SHI_TOMASI
};

class HarrisDetector : Detector {
public:
    HarrisScoreType type; 
    int gaussian_size; 
    double k;
    HarrisDetector(HarrisScoreType type, int gaussian_size, double k = 0) :
        type(type), gaussian_size(gaussian_size), k(k) {}

    Img_lf getScore(const Img &gray) {
        assert(gray.channels == 1);

        int width = gray.width;
        int height = gray.height;
        int channels = gray.channels;

        Img_i gradient_x, gradient_y;
        sobel(gray, &gradient_x, &gradient_y, SOBEL);

        Img_lf xx(width, height);
        Img_lf yy(width, height);
        Img_lf xy(width, height);
        INVOKE_MULTI_THREADS(height, start, end, {
        for (int y = start; y < end; ++y)
            for (int x = 0; x < width; ++x) {
                xx(x, y) = gradient_x(x, y) * gradient_x(x, y);
                xy(x, y) = gradient_x(x, y) * gradient_y(x, y);
                yy(x, y) = gradient_y(x, y) * gradient_y(x, y);
            }
        });
        gradient_x.release();
        gradient_y.release();

        int n = gaussian_size;
        xx.swap(gaussian<double>(xx, n, n, n / 3.));
        yy.swap(gaussian<double>(yy, n, n, n / 3.));
        xy.swap(gaussian<double>(xy, n, n, n / 3.));

        Img_lf res(width, height);
        INVOKE_MULTI_THREADS(height, start, end, {
        for (int y = start; y < end; ++y)
            for (int x = 0; x < width; ++x) {
                double det = 1LL * xx(x, y) * yy(x, y) - 
                             1LL * xy(x, y) * xy(x, y);
                double trace = xx(x, y) + yy(x, y);

                if (type == HARRIS)
                    res(x, y) = det - k * trace * trace;
                else if (type == SHI_TOMASI)
                    res(x, y) = (trace - sqrt(trace * trace - 4 * det)) / 2; 
            }
        });
        xx.release();
        xy.release(); 
        yy.release();
        return res;
    }
    int detect(const Img &gray, std::vector<KeyPoint> *keypoints) {
        int width  = gray.width;
        int height = gray.height;
        int winsize_x = 5;
        int winsize_y = 5;
        int center_x = winsize_x / 2;
        int center_y = winsize_y / 2;

        double nonmax = -1.;
        Img_lf score = getScore(gray);
        score.swap(nonMaximalSupression(score, 5, nonmax));

        double global_max = -1;
        for (int y = 0; y < height; ++y)
            for (int x = 0; x < width; ++x) {
                double t = score(x, y);
                if (t != nonmax && t > global_max)
                    global_max = t;
            }
        for (int y = 0; y < height; ++y)
            for (int x = 0; x < width; ++x)
                if (score(x, y) > global_max * 0.01)
                    keypoints->push_back(KeyPoint(x, y));
        
        score.release();
        return keypoints->size();
    }
};

