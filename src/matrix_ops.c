#include "matrix_ops.h"

double get_distance(xyz a, xyz b)
{
    double x_diff = a.x - b.x;
    double y_diff = a.y - b.y;
    double z_diff = a.z - b.z;
    double dist = sqrt(x_diff*x_diff + y_diff*y_diff + z_diff*z_diff);
    return dist;
}

/*  From a to b */
xyz get_unit_vector(xyz a, xyz b)
{
    double dist = get_distance(a, b);
    double sq_r_dist = sqrt(dist);

    xyz unit_vector;
    unit_vector.x = (b.x - a.x)/sq_r_dist;
    unit_vector.y = (b.y - a.y)/sq_r_dist;
    unit_vector.y = (b.z - a.z)/sq_r_dist;
    return unit_vector;
}

xyz ijk_to_xyz(ijk a, xyz voxel_dim)
{
    xyz tmp;
    tmp.x = voxel_dim.x * (a.i + 0.5);
    tmp.y = voxel_dim.y * (a.j + 0.5);
    tmp.z = voxel_dim.z * (a.k + 0.5);
    return tmp;
}

ijk ind_to_ijk(long ind, ijk volume_dim)
{
    int nx = volume_dim.i;
    int ny = volume_dim.j;

    ijk tmp;

    tmp.k = ind / (nx*ny);
    long left_over = ind % (nx*ny);
    tmp.j = left_over / nx;
    tmp.i = left_over % nx;

    return tmp;
}

long ijk_to_ind(ijk a, ijk volume_dim)
{
    int nx = volume_dim.i;
    int ny = volume_dim.j;

    long ind = nx*ny*a.k + nx*a.j + a.i;
    return ind;
}

ijk xyz_to_ijk(xyz a, xyz voxel_dim)
{
    xyz fuzzy_min;
    xyz fuzzy_max;
    ijk guess1;
    ijk guess2;


    fuzzy_min.x = a.x / voxel_dim.x - 1;
    fuzzy_min.y = a.y / voxel_dim.y - 1;
    fuzzy_min.z = a.z / voxel_dim.z - 1;

    fuzzy_max.x = a.x / voxel_dim.x;
    fuzzy_max.y = a.y / voxel_dim.y;
    fuzzy_max.z = a.z / voxel_dim.z;

    guess1.i = (int)ceil(fuzzy_min.x);
    guess1.j = (int)ceil(fuzzy_min.y);
    guess1.k = (int)ceil(fuzzy_min.z);

    guess2.i = (int)floor(fuzzy_max.x);
    guess2.j = (int)floor(fuzzy_max.y);
    guess2.k = (int)floor(fuzzy_max.z);

    int all_good = (guess1.i == guess2.i) && (guess1.j == guess2.j) &&
                   (guess1.k == guess2.k);
    if (all_good) {
        return guess1;
    }
    else {
        xyz b;
        b.x = a.x - voxel_dim.x/10;
        b.y = a.y - voxel_dim.y/10;
        b.z = a.z - voxel_dim.z/10;
        return xyz_to_ijk(b, voxel_dim);
    }
}