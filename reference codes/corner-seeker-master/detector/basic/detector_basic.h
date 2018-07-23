#pragma once
#include "image_basic.h"
#include "multi_threads.h"

#include <assert.h>
#include <vector>

class Detector {
public:
    Detector() {}
    virtual int detect(const Img &img, std::vector<KeyPoint> *keypoints) = 0;
};