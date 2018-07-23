#pragma once
#include "basic/image_basic.h"

enum CannyNorm {
    L1, L2
};
Img canny(const Img &gray, 
          double threshold_low = 0, double threshold_high = 0,
          CannyNorm canny_norm = L2, 
          SobelType sobel_type = SCHARR) {
    int width = gray.width;
    int height = gray.height;

    // use soble to compute the gradient, here we use scharr, a more stable version of it.

    Matrix3D<int> gradient_x, gradient_y;
    sobel(gray, &gradient_x, &gradient_y, sobel_type);

    // non-maximum supression

    Matrix3D<int> activity(width, height);
    Matrix3D<unsigned char> isEdge(width, height);

    INVOKE_MULTI_THREADS(height, start, end, {
    for (int y = start; y < end; ++y)
        for (int x = 0; x < width; ++x) {
            int gx = gradient_x(x, y);
            int gy = gradient_y(x, y);
            if (canny_norm == L2)
                activity(x, y) = gx * gx + gy * gy;
            else
                activity(x, y) = abs(gx) + abs(gy);
        }
    });

    double PI = acos(-1.);
    INVOKE_MULTI_THREADS(height, start, end, {
    for (int y = start; y < end; ++y)
        for (int x = 0; x < width; ++x) {
            isEdge(x, y) = 0;
            if (y <= 1 || x <= 1 || x >= width-2 || y >= height-2)
                continue;
            double theta = atan2(gradient_y(x, y), gradient_x(x, y));
            if (theta < 0)
                theta += PI;
            int k = int(round((theta) / (PI / 4))) & 3;
            int v = activity(x, y);
            if (k == 0) {
                if (v > activity(x+1, y) && v >= activity(x-1, y))
                    isEdge(x, y) = 255;
            }
            else if (k == 1) {
                if (v > activity(x+1, y+1) && v >= activity(x-1, y-1))
                    isEdge(x, y) = 255;
            }
            else if (k == 2) {
                if (v > activity(x, y+1) && v >= activity(x, y-1))
                    isEdge(x, y) = 255; 
            }
            else if (k == 3) {
                if (v > activity(x-1, y+1) && v >= activity(x+1, y-1))
                    isEdge(x, y) = 255;
            }
        }
    });

    // double threshold
    // here we use a simple adaptive method is used if the higher one is set to 0.

    if (threshold_high == 0) {
        int sum = 0;
        for (int y = 0; y < height; ++y)
            for (int x = 0; x < width; ++x) {
                sum += gray(x, y);
            }
        threshold_high = 1.33 * sum / height / width;
        threshold_low  = 0.67 * sum / height / width;
    }
    if (canny_norm == L2) {
        threshold_low  = threshold_low  * threshold_low; 
        threshold_high = threshold_high * threshold_high;
    }

    bool *vis = new bool[height * width];
    int *qx = new int[height * width];
    int *qy = new int[height * width];
    int cnt = 0;

    for (int i = height * width; i--; )
        vis[i] = false;

    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x) {
            if (isEdge(x, y) == 255 && activity(x, y) > threshold_high) {
                ++cnt;
                qx[cnt] = x;
                qy[cnt] = y;
                vis[y*width + x] = true;
            }
        }

    // edge tracking by hysteresis

    for (int i = 1; i <= cnt; ++i) {
        int x = qx[i], y = qy[i];
        for (int j = -2; j <= 2; ++j)
            for (int k = -2; k <= 2; ++k) {
                int tx = x + j;
                int ty = y + k;
                BDCHK(tx, ty);
                if (vis[ty*width + tx] == false && 
                    isEdge(tx, ty) == 255 && activity(tx, ty) > threshold_low) {
                    vis[ty*width + tx] = true;
                    ++cnt;
                    qx[cnt] = tx;
                    qy[cnt] = ty;
                }
            }
    }

    for (int y = 0; y < height; ++y) 
        for (int x = 0; x < width; ++x)
            if (vis[y*width + x] == false)
                isEdge(x, y) = 0;

    gradient_x.release();
    gradient_y.release();
    activity.release();
    delete vis;
    delete qx;
    delete qy;

    return isEdge;
}