#include <stdio.h>
#include <stdlib.h>
#include "image.h"

ImageInfo* draw_line_x(ImageInfo* pImg, Coords* start, Coords* end, unsigned int color);
ImageInfo* draw_line_y(ImageInfo* pImg, Coords* start, Coords* end, unsigned int color);

void draw_line(ImageInfo* pImg, Coords start, Coords end, unsigned int color)
{
    color %= 2;
    int delta_x = end.pos_x - start.pos_x;
    int delta_y = end.pos_y - start.pos_y;
    if (end.pos_x < start.pos_x)    // inverting Coords
    {
        int temp_x = end.pos_x;
        int temp_y = end.pos_y;

        end.pos_x = start.pos_x;
        start.pos_x = temp_x;

        end.pos_y = start.pos_y;
        start.pos_y = temp_y;
    }
    if (abs(delta_x) >= abs(delta_y))
    {
        draw_line_x(pImg, &start, &end, color);
    }
    else
    {
        draw_line_y(pImg, &start, &end, color);
    }
}

void draw_example_circle(ImageInfo *pImg, Coords centre, int radius, unsigned int spacing, unsigned int color)
{
    Coords end;
    int x = radius;
    int y = 0;
    int err = 0;

    while (x >= y) {

        // Drawing the rays from the centre point
        end.pos_x = centre.pos_x + x; end.pos_y = centre.pos_y + y;
        draw_line(pImg, centre, end, color);

        end.pos_x = centre.pos_x + y; end.pos_y = centre.pos_y + x;
        draw_line(pImg, centre, end, color);

        end.pos_x = centre.pos_x - x; end.pos_y = centre.pos_y + y;
        draw_line(pImg, centre, end, color);

        end.pos_x = centre.pos_x - y; end.pos_y = centre.pos_y + x;
        draw_line(pImg, centre, end, color);

        end.pos_x = centre.pos_x + x; end.pos_y = centre.pos_y - y;
        draw_line(pImg, centre, end, color);

        end.pos_x = centre.pos_x + y; end.pos_y = centre.pos_y - x;
        draw_line(pImg, centre, end, color);

        end.pos_x = centre.pos_x - x; end.pos_y = centre.pos_y - y;
        draw_line(pImg, centre, end, color);

        end.pos_x = centre.pos_x - y; end.pos_y = centre.pos_y - x;
        draw_line(pImg, centre, end, color);

        if (err <= 0) {
            y += spacing;
            err += 2 * y + 1;
        }
        if (err > 0) {
            x -= spacing;
            err -= 2 * x + 1;
        }
    }
}

int main(int argc, char *argv[])
{
    if (sizeof(bmpHdr) != 54)
    {
        printf("Size of the bitmap header is invalid (%ld). Please, check compiler options.\n", sizeof(bmpHdr));
        return 1;
    }

    ImageInfo *pImg = readBmp("black256x256.bmp");
    if (pImg == NULL)
    {
        printf("Error opening input file black256x256.bmp\n");
        return 1;
    }

    Coords start;
    start.pos_x = 127;
    start.pos_y = 127;

    draw_example_circle(pImg, start, 126, 5, 1);

    saveBmp("result.bmp", pImg);
    freeImage(pImg);

    pImg = readBmp("white256x256.bmp");
    if (pImg == NULL)
    {
        printf("Error opening input file white256x256.bmp\n");
        return 1;
    }

    start.pos_x = 127;
    start.pos_y = 127;

    draw_example_circle(pImg, start, 126, 5, 0);

    saveBmp("result2.bmp", pImg);
    freeImage(pImg);

    return 0;
}
