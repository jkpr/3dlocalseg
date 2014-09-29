#ifndef MATRIX_OPS_H
#define MATRIX_OPS_H

#include <math.h>

typedef struct
{
    double x;
    double y;
    double z;
} xyz;

typedef struct
{
    int i;
    int j;
    int k;
} ijk;


double get_distance(xyz a, xyz b);

/*  From a to b */
xyz get_unit_vector(xyz a, xyz b);
xyz ijk_to_xyz(ijk a, xyz voxel_dim);
ijk ind_to_ijk(long ind, ijk volume_dim);

long ijk_to_ind(ijk a, ijk volume_dim);

ijk xyz_to_ijk(xyz a, xyz voxel_dim);

#endif