#pragma once
#include "basic/detector_basic.h"

// segment test only, no accleration from ID3

class SegmentTestDetector : Detector {
public:
    int n;
    int t;

    /*  I'm confused about the declaration of these static members.
        If constexpr is used, then they are inaccessible in the following calls
        and therefore compile error occurs.
        My way to hack it is to make them no longer constant, while the code 
        becomes less readable.

        Their initializations are declared at the end.
    */

    static int dx[16];
    static int dy[16];
    static Img_i empty_mask;

    SegmentTestDetector(const int &n, const int &t) : n(n), t(t) {}

    Img_i getScore(const Img &gray, const Img_i &mask = empty_mask) {
        // the equation (8) in the original paper is used.
        int width = gray.width;
        int height = gray.height;
        bool isEmptyMask = mask.data == nullptr;

        Img_i res(width, height);
        INVOKE_MULTI_THREADS(height, start, end, {
        for (int y = start; y < end; ++y)
            for (int x = 0; x < width; ++x) {
                if (!isEmptyMask && mask(x, y) < n) {
                    res(x, y) = -1;
                    continue;
                }
                int v = gray(x, y);
                int bright = 0;
                int dark = 0;
                for (int i = 0; i < 16; ++i) {
                    int d = gray(x + dx[i], y + dy[i]) - v;
                    if (d > t)
                        bright += d - t; 
                    else if (d < -t)
                        dark += -(d + t);  
                }
                res(x, y) = std::max(bright, dark);
            }
        });
        return res;
    }
    Img_i getSegLength(const Img &gray) {
        // the equation (8) in the original paper is used.
        int width = gray.width;
        int height = gray.height;

        Img_i res(width, height);
        INVOKE_MULTI_THREADS(height, start, end, {
        for (int y = start; y < end; ++y)
            for (int x = 0; x < width; ++x) {
                int v = gray(x, y);
                int &r = res(x, y);
                int last_s = -2;
                int cnt; 
                int prefix_cnt = 0;
                int prefix_s = 1;
                r = 0;
                for (int i = 0; i < 16; ++i) {
                    int d = gray(x + dx[i], y + dy[i]) - v;
                    int s = d > t ? 1 : (d < -t ? -1 : 0);
                    if (s != last_s) {
                        cnt = 0; last_s = s;
                    }
                    if (++cnt == i+1) {
                        prefix_cnt = cnt; prefix_s = s;
                    }
                    if (cnt > r && last_s)
                        r = cnt;
                }
                if (prefix_s == last_s && prefix_cnt + cnt > r && last_s)
                    r = prefix_cnt + cnt;
            }
        });
        return res;
    }
    int detect(const Img &gray, std::vector<KeyPoint> *keypoints) {
        int width  = gray.width;
        int height = gray.height;

        Img_i mask = getSegLength(gray);
        Img_i score = getScore(gray, mask);

        int nonmax = -1;
        score.swap(nonMaximalSupression(score, 3, nonmax));

        for (int y = 0; y < height; ++y)
            for (int x = 0; x < width; ++x)
                if (score(x, y) != nonmax)
                    keypoints->push_back(KeyPoint(x, y));

        mask.release();
        score.release();
        return keypoints->size();
    }
};

typedef SegmentTestDetector FASTDetector;

Img_i FASTDetector::empty_mask = Img_i(0, 0, 0, nullptr);

int FASTDetector::dx[16] = {0, 1, 2, 3, 3, 3, 2, 1,
                            0,-1,-2,-3,-3,-3,-2,-1};
int FASTDetector::dy[16] = {-3,-3,-2,-1, 0, 1, 2, 3,
                             3, 3, 2, 1, 0,-1,-2,-3};