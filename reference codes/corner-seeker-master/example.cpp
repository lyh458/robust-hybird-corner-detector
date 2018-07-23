// make this define a comment to disable multi threads for matrix3D
#define MULTI_THREADS_FOR_MATRIX3D

#include "detector/detectors.h"
#include <ctime>
#include <iostream>

#define STB_IMAGE_IMPLEMENTATION
#include "detector/basic/stb_image.h"

#ifdef STB_IMAGE_WRITE_IMPLEMENTATION
#else
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "detector/basic/stb_image_write.h"
#endif

int main(int argc, char **argv) {
    fprintf(stderr, "num_cores: %d\n", multi_threads::num_cores);

    int width;
    int height;
    int channels;

    unsigned char *data_rgb  = stbi_load(argv[1], &width, &height, &channels, 3);
    unsigned char *data_gray = stbi_load(argv[1], &width, &height, &channels, 1);

    Img img (width, height, 3, data_rgb);
    Img gray(width, height, 1, data_gray);

    HarrisDetector *harris = new HarrisDetector(SHI_TOMASI, 5);
    FASTDetector   *fast   = new FASTDetector(9, 20);
    CSSDetector    *css    = new CSSDetector(50, 150); // better
    //CSSDetector    *css    = new CSSDetector(0, 0);
    std::vector<KeyPoint> keypoints;
    
    //std::cerr << harris->detect(gray, &keypoints) << std::endl;
    std::cerr << css->detect(gray, &keypoints) << std::endl;

    for (int i = 0; i < keypoints.size(); ++i) {
        mark_keypoint_with_r3(img, keypoints[i], GREEN);
    }

    stbi_write_png("test-marked.png", width, height, 3, img.data, 0);
}