#pragma once
#include <cmath>
#include <cstdio> 

// make this define a comment to disable multi threads for matrix3D
//#define MULTI_THREADS_FOR_MATRIX3D
#include "multi_threads.h"

#define BDCHK(x, y) if (x < 0 || x >= width || y < 0 || y >= height) continue

template <typename type> struct Matrix3D {
    int width;
    int height;
    int channels;
    type *data;

    static type* malloc(int n) { return new type[n]; }
    void release()             { delete data; }
    void swap(const Matrix3D<type> &des) { release(); data = des.data; }

    Matrix3D() {}
    Matrix3D(int width, int height, int channels = 1) :
        width(width), height(height), channels(channels) { 
        data = malloc(height * width * channels);
    }
    Matrix3D(int width, int height, int channels, type *data) :
        width(width), height(height), channels(channels), data(data) {}

    inline int index(const int &x, const int &y, const int &c = 0) const {
        return (y * width + x) * channels + c;
    }
    inline type &operator () (const int &x, const int &y, 
                              const int &c = 0) const {
        return data[index(x, y, c)];
    }
    inline type &at(const int &x, const int &y, const int &c = 0) const {
        return data[index(x, y, c)];
    }
    inline type at_zerofill(const int &x, const int &y, 
                            const int &c = 0) const {
        if (x < 0 || x >= width || y < 0 || y >= height)
            return 0;
        return data[index(x, y, c)];
    }
    inline type at_replicate(int x, int y, const int &c = 0) const {
        if (x >= width)  x = width - 1;
        else if (x < 0)  x = 0;
        if (y >= height) y = height - 1;
        else if (y < 0)  y = 0;
        return data[index(x, y, c)];
    }
    inline type at_cycle(int x, int y, const int &c = 0) const {
        if (x >= width)  x -= width;
        else if (x < 0)  x += width;
        if (y >= height) y -= height;
        else if (y < 0)  y += height;
        return data[index(x, y, c)];
    }
};

typedef Matrix3D<unsigned char> Img;
typedef Matrix3D<double>        Img_lf;
typedef Matrix3D<float>         Img_f;
typedef Matrix3D<int>           Img_i;

enum BorderType {
    CYCLE, REPLICATE, ZEROFILL
};
template <typename type_des, typename type_src, typename type_app> 
Matrix3D<type_des> filter2D(const Matrix3D<type_src> &img, 
                            const Matrix3D<type_app> &filter, 
                            BorderType border_type) {
    int winsize_x = filter.width;
    int winsize_y = filter.height;
    int center_x  = winsize_x / 2; 
    int center_y  = winsize_y / 2;
    int width = img.width;
    int height = img.height;
    int channels = img.channels;   

    Matrix3D<type_des> res(width, height, channels);

    bool single_filter = (filter.channels == 1);

    INVOKE_MULTI_THREADS(height, start, end, {
    for (int y = start; y < end; ++y)
        for (int x = 0; x < width; ++x)
            for (int c = 0; c < channels; ++c) { 
                type_app r = 0; 
                for (int i = 0; i < winsize_x; ++i)
                    for (int j = 0; j < winsize_y; ++j) {
                        type_src v;
                        if (border_type == CYCLE) 
                            v = img.at_cycle(x-i+center_x, y-j+center_y, c); 
                        else if (border_type == REPLICATE)
                            v = img.at_replicate(x-i+center_x, y-j+center_y, c);
                        else if (border_type == ZEROFILL)
                            v = img.at_zerofill(x-i+center_x, y-j+center_y, c);
                        if (single_filter)                    
                            r += v * filter(i, j);
                        else
                            r += v * filter(i, j, c);
                    }
                res(x, y, c) = r;
            }
    });
    return res;
}

Matrix3D<double> get_gaussian_ker(int n, int m, double sigma) {
    Matrix3D<double> opr(n, m);
    double norm_fac = 0;
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < m; ++j) {
            opr(i, j) = exp(-((i-n/2)*(i-n/2)+(j-m/2)*(j-m/2))/(2*sigma*sigma));
            norm_fac += opr(i, j);
        }
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < m; ++j) 
            opr(i, j) /= norm_fac;
    return opr;
}

template <typename type_des, typename type>
Matrix3D<type_des> gaussian(const Matrix3D<type> &img, int n, int m, 
                            double sigma, 
                            BorderType border_type = REPLICATE) {
    Matrix3D<double> opr = get_gaussian_ker(n, m, sigma);
    Matrix3D<type_des> res = filter2D<type_des>(img, opr, border_type);
    opr.release();
    return res;
}

enum SobelType {
    SOBEL, SCHARR
};
template <typename type_des, typename type>
void sobel(const Matrix3D<type> &img,
           Matrix3D<type_des> *gx, Matrix3D<type_des> *gy, 
           SobelType sobel_type = SOBEL) { 
    // gx and gy shouldn't call malloc
    static int  sobel[9] = {1, 2, 1, 0, 0, 0, -1, -2, -1};
    static int scharr[9] = {3,10, 3, 0, 0, 0, -3,-10, -3};

    int *opr = (sobel_type == SOBEL) ? sobel : scharr;

    Matrix3D<int> opr_x(3, 3);
    Matrix3D<int> opr_y(3, 3);
    for (int i = 0; i < 3; ++i)
        for (int j = 0; j < 3; ++j) {
            opr_x(i, j) = opr[opr_x.index(j, i)];
            opr_y(i, j) = opr[opr_y.index(i, j)];
        }
    *gx = filter2D<type_des>(img, opr_x, REPLICATE);
    *gy = filter2D<type_des>(img, opr_y, REPLICATE);
    opr_x.release();
    opr_y.release();
}
template <typename type>
Matrix3D<type> nonMaximalSupression(const Matrix3D<type> &img, 
                                    int winsize, type nonmax) {
    int width  = img.width;
    int height = img.height;
    int channels = img.channels;
    int center_x = winsize / 2;
    int center_y = winsize / 2;
    Matrix3D<type> res(width, height, channels);

    INVOKE_MULTI_THREADS(height, start, end, {
    for (int y = start; y < end; ++y)
        for (int x = 0; x < width; ++x)
            for (int c = 0; c < channels; ++c) { 
                type v = img(x, y, c);
                bool isMaximum = true;
                for (int i = 0; i < winsize && isMaximum; ++i)
                    for (int j = 0; j < winsize && isMaximum; ++j) {
                        if (i == center_x && j == center_y) continue;
                        if (img.at_replicate(x-i+center_x,y-j+center_y, c) >= v)
                            isMaximum = false;
                    }
                res(x, y, c) = isMaximum ? v : nonmax;
            }
    });
    return res;
} 

struct KeyPoint {
    double x, y;
    KeyPoint() {}
    KeyPoint(double _x, double _y) : x(_x), y(_y) {}
};

struct Color {
    unsigned char r, g, b;
    Color(unsigned char r, unsigned char g, unsigned char b) : r(r), g(g), b(b) {}
};

const Color RED   = Color(255, 0, 0);
const Color BLUE  = Color(0, 0, 255);
const Color GREEN = Color(0, 255, 0);
const Color WHITE = Color(255, 255, 255);
const Color BLACK = Color(0, 0, 0);

void mark_keypoint_with_r3(Img &img, const KeyPoint &keypoint, const Color &color) {
    static const int dx[16] = {0, 1, 2, 3, 3, 3, 2, 1,
                               0,-1,-2,-3,-3,-3,-2,-1};
    static const int dy[16] = {-3,-3,-2,-1, 0, 1, 2, 3,
                                3, 3, 2, 1, 0,-1,-2,-3};
    int x = int(keypoint.x);
    int y = int(keypoint.y);
    int width  = img.width;
    int height = img.height;
    for (int i = 0; i < 16; ++i) {
        BDCHK(x+dx[i], y+dy[i]);
        img(x+dx[i], y+dy[i], 0) = color.r;
        img(x+dx[i], y+dy[i], 1) = color.g;
        img(x+dx[i], y+dy[i], 2) = color.b;
    }
}