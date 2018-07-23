#pragma once
#include "basic/image_basic.h"
#include <vector>

enum ContourType { LINE, CLOSED };

struct Contour {
    ContourType type;
    std::vector <int> *xt, *yt;
    
    Contour() {
        type = LINE;
        xt = new std::vector<int>;
        yt = new std::vector<int>;
    }
    int size() const { return xt->size(); }
    int x(int n) const { return xt->at(n); }
    int y(int n) const { return yt->at(n); }
    void release() {
        xt->clear();
        xt->shrink_to_fit();
        yt->clear();
        yt->shrink_to_fit();
    }
};

std::vector<Contour> findContours(const Img &isEdgeInput) {  
    // isEdgeInput is the output image of your canny algorithm with size (width, height, 1)
    // if pixel (x, y) is an edge, set it to 255, otherwise 0.

    int width = isEdgeInput.width;
    int height = isEdgeInput.height;
    Img isEdge(width, height);
    std::vector<Contour> contours;

    static int dx[8] = {1, 1, 0, -1, -1, -1, 0, 1};
    static int dy[8] = {0, 1, 1,  1,  0, -1,-1,-1};

    Matrix3D<bool> vis(width, height);
    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x) {
            isEdge(x, y) = isEdgeInput(x, y); 
            vis(x, y) = false;
        }

    int *qx = new int[width * height];
    int *qy = new int[width * height];
    int **edge = (int**) malloc(width * height * sizeof(int*));

    for (int i = 0; i < width * height; ++i) {
        edge[i] = new int[3]; 
        edge[i][0] = 0;
    }

    int idr, ids;
    for (int sy = 0; sy < height; ++sy)
        for (int sx = 0; sx < width; ++sx) {
            if (isEdge(sx, sy) == 255 && vis(sx, sy) == false) {
                for (int j = 0; j < 8; j += 2) {
                    BDCHK(sx+dx[j], sy+dy[j]);
                    if (vis(sx+dx[j], sy+dy[j]))
                        vis(sx, sy) = true; 
                }
                if (vis(sx, sy) == true) {
                    isEdge(sx, sy) = false;
                    vis(sx, sy) = false;
                    continue;
                }

                int cnt = 0;
                int dir = 0;
                int x = sx;
                int y = sy;
                bool find_next = true;
                while (find_next) {
                    vis(x, y) = true;
                    find_next = false;
                    ++cnt;
                    qx[cnt] = x, qy[cnt] = y;
                    for (int i = 0; i < 8; ++i) {
                        int tx = x + dx[(dir+i)&7];
                        int ty = y + dy[(dir+i)&7];
                        int adj = 0;
                        BDCHK(tx, ty);
                        if (isEdge(tx, ty) == 255 && vis(tx, ty) == false) {
                            for (int j = 0; j < 8; j += 2) {
                                BDCHK(tx+dx[j], ty+dy[j]);
                                adj += (vis(tx+dx[j], ty+dy[j]) == true);
                            }
                            if (adj >= 2)
                                continue; 
                            find_next = true;
                            idr = y*width+x, ids = ty*width+tx;
                            edge[idr][++edge[idr][0]] = ids;
                            edge[ids][++edge[ids][0]] = idr;
                            x = tx, y = ty, dir = (i+6)&7;
                            break;
                        }
                    }
                }
                int cnt1 = cnt;

                x = sx, y = sy, dir = 4;
                find_next = true;
                while (find_next) {
                    vis(x, y) = true;
                    find_next = false;
                    ++cnt;
                    qx[cnt] = x, qy[cnt] = y;
                    for (int i = 8; i--; ) {
                        int tx = x + dx[(dir+i)&7];
                        int ty = y + dy[(dir+i)&7];
                        int adj = 0;
                        BDCHK(tx, ty);
                        if (isEdge(tx, ty) == 255 && vis(tx, ty) == false) {
                            for (int j = 0; j < 8; j += 2) {
                                BDCHK(tx+dx[j], ty+dy[j]);
                                adj += (vis(tx+dx[j], ty+dy[j]) == true);
                            }
                            if (adj >= 2)
                                continue; 
                            find_next = true;
                            idr = y*width+x, ids = ty*width+tx;
                            edge[idr][++edge[idr][0]] = ids;
                            edge[ids][++edge[ids][0]] = idr;
                            x = tx, y = ty, dir = (i+2)&7;
                            break;
                        }
                    }
                }
            }
        }

    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x) {
            for (int i = -2; i <= 2; ++i)
                for (int j = -2; j <= 2; ++j) {
                    int tx = x + i;
                    int ty = y + j;
                    BDCHK(tx, ty);

                    idr = y*width+x, ids = ty*width+tx;    
                    if (edge[idr][0] != 1 || edge[ids][0] != 1)
                        continue;
                    if (idr == ids)
                        continue;
                    if (std::max(abs(tx - x), abs(ty - y)) <= 1) {
                        edge[ids][++edge[ids][0]] = idr;
                        edge[idr][++edge[idr][0]] = ids;
                        continue;
                    }

                    int dx = (tx + x) / 2;
                    int dy = (ty + y) / 2;
                    int idt = dy*width + dx;

                    if (edge[ids][0] == 1 && edge[idt][0] == 0) {
                        edge[idt][++edge[idt][0]] = ids;
                        edge[idt][++edge[idt][0]] = idr;
                        edge[idr][++edge[idr][0]] = idt;
                        edge[ids][++edge[ids][0]] = idt;
                    }
                }
       }

    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x) {
            idr = y*width + x;
            if (edge[idr][0] == 2) {
                int ax = edge[idr][1] % width;
                int ay = edge[idr][1] / width;
                int bx = edge[idr][2] % width;
                int by = edge[idr][2] / width;

                if (std::max(abs(ax - bx), abs(by - ay)) <= 1) {
                    for (int i = 1; i <= 2; ++i)
                        for (int j = 1; j <= 2; ++j)
                            if (edge[edge[idr][1]][i] == idr && 
                                edge[edge[idr][2]][j] == idr) {
                                edge[edge[idr][1]][i] = edge[idr][2];
                                edge[edge[idr][2]][j] = edge[idr][1];
                                edge[idr][0] = 0;
                            }
                }                    
            }
        }

    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x) {
            vis(x, y) = false;
        }

    for (int sd = 1; sd <= 2; ++sd)
    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x) {
            idr = y*width + x;
            if (vis(x, y) == false && edge[idr][0] == sd) {

                int cur = idr, last = -1;
                int cnt = 0;
                while (true) {
                    ++cnt;
                    qy[cnt] = cur / width, qx[cnt] = cur % width;
                    vis(qx[cnt], qy[cnt]) = true;
                    bool find_next = false;
                   
                    for (int i = 1; i <= edge[cur][0]; ++i) {
                        int dy = edge[cur][i] / width;
                        int dx = edge[cur][i] % width;
                        if (vis(dx, dy) == false) {
                            last = cur, cur = edge[cur][i], find_next = true;
                            break;
                        }
                    }
                    if (find_next == false)
                        break;
                }
                if (cnt <= 7)
                    continue;

                Contour contour;
                for (int i = 1; i <= cnt; ++i) {
                    contour.xt->push_back(qx[i]);
                    contour.yt->push_back(qy[i]);
                }
                if (sd == 2)
                    contour.type = CLOSED;
                contours.push_back(contour);
            }
        }

    for (int i = 0; i < width * height; ++i)
        delete edge[i];
    delete qx;
    delete qy;
    delete edge;

    isEdge.release();

    return contours;
}
std::vector<KeyPoint> findTcorners(const Img &isEdge, 
                                   const std::vector<Contour> &contours) {
    std::vector<KeyPoint> Tcorners;

    int width = isEdge.width;
    int height = isEdge.height;
    Matrix3D<int> ids(width, height);

    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x)
            ids(x, y) = -1;

    int m = contours.size();
    for (int s = 0; s < m; ++s)
        for (int k = contours[s].size(); k--; )
            ids(contours[s].x(k), contours[s].y(k)) = s;

    int tk[4];
    for (int s = 0; s < m; ++s) {
        if (contours[s].type == CLOSED)
            continue;
        int m = contours[s].size();

        for (int k = 0; k < 5; ++k) {
            ids(contours[s].x(k), contours[s].y(k)) = -1;
            ids(contours[s].x(m-k-1), contours[s].y(m-k-1)) = -1;
        }

        for (int k = 0; k < m; k += m-1) {
            int x = contours[s].x(k);
            int y = contours[s].y(k);

            bool isTT = false;
            for (int i = -3; i <= 3; ++i)
                for (int j = -3; j <= 3; ++j) {
                    int tx = x + i;
                    int ty = y + j;
                    BDCHK(tx, ty);

                    if (ids(tx, ty) != -1) {
                        int t = ids(tx, ty);
                        tk[0] = 0, tk[1] = 1;
                        tk[2] = contours[t].size() - 1, tk[3] = tk[2] - 1;

                        bool isT = true;
                        for (int p = 0; p < 4; ++p) {
                            int dx = contours[t].x(tk[p]);
                            int dy = contours[t].y(tk[p]);

                            if (t == s && abs(k-tk[p]) <= 1)
                                continue;

                            if (std::max(abs(tx - dx), abs(ty - dy)) <= 3)
                                isT = false;
                        }
                        if (isT == true)
                            isTT = true;
                    }
                }
            if (isTT == true)
                Tcorners.push_back(KeyPoint(x, y));
        }

        for (int k = 0; k < 5; ++k) {
            ids(contours[s].x(k), contours[s].y(k)) = s;
            ids(contours[s].x(m-k-1), contours[s].y(m-k-1)) = s;
        }
    }   
    ids.release();
    return Tcorners;
}
