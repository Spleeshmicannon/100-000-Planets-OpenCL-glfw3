#define MATRIX_HEIGHT 100000
#define MATRIX_WIDTH 5

#define MASS 0
#define X 1
#define Y 2
#define DX 3
#define DY 4
#define G 0.000006743f

__kernel void planetCalc(__global float planet[MATRIX_HEIGHT][MATRIX_WIDTH], __global float outPlanet[MATRIX_HEIGHT][2])
{
	// Get the index of the current element to be processed
	__private int i = get_global_id(0);
	__private float fx = 0, fy = 0;

	for (int j = 0; j < MATRIX_HEIGHT; ++j) // B
	{
		if (j == i) continue;
		__private float F, rx, ry;

		rx = planet[i][X] - planet[j][X]; // A - B
		ry = planet[i][Y] - planet[j][Y]; // A - B

		F = (planet[i][MASS] * planet[j][MASS] * G) /
			(((rx * rx) + (ry * ry)) + 0.00000000000001f);

		fx += (-F * rx) + 0.00000000000001f; // A
		fy += (-F * ry) + 0.00000000000001f; // A
	}

	planet[i][DX] += (fx / planet[i][MASS]);
	planet[i][DY] += (fy / planet[i][MASS]);

	planet[i][X] += planet[i][DX];
	planet[i][Y] += planet[i][DY];

	outPlanet[i][0] = planet[i][X];
	outPlanet[i][1] = planet[i][Y];
}

__kernel void image_make_black(__write_only image2d_t image)
{
	write_imagef(image, (int2) (get_global_id(0), get_global_id(1)), (float4)(0, 0, 0, 0));
}

__kernel void image_draw_planets(__write_only image2d_t image, __global float outPlanet[MATRIX_HEIGHT][2])
{
	write_imagef(image, (int2) (outPlanet[get_global_id(0)][0], outPlanet[get_global_id(0)][1]), (float4)(255, 255, 255, 255));
}