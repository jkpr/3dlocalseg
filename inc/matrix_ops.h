#ifndef MATRIX_OPS_H
#define MATRIX_OPS_H

#include <math.h>
#include <stdlib.h>
#include <stdio.h>

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

typedef struct
{
    long * ptr;
    int size;
} long_arr;

float get_min(float a, float b);
float get_max(float a, float b);

double get_min_side(xyz a);
double get_distance(xyz a, xyz b);
double get_distance_one(xyz a);

int get_sum_sides(ijk a);

/*  From a to b */
xyz get_unit_vector(xyz a, xyz b);
xyz get_unit_vector_one(xyz a);

ijk ind_to_ijk(long ind, ijk volume_dim);
long ijk_to_ind(ijk a, ijk volume_dim);

xyz ijk_to_xyz(ijk a, xyz voxel_dim);
ijk xyz_to_ijk(xyz a, xyz voxel_dim);

long xyz_to_ind(xyz a, xyz voxel_dim, ijk volume_dim);
xyz ind_to_xyz(long ind, xyz voxel_dim, ijk volume_dim);

int add_ind(long ind, long * r_inds, int r_inds_size);
int is_inside_vol(xyz a, xyz voxel_dim, ijk volume_dim);
long_arr get_radius_inds(long voxel, long seed, xyz voxel_dim, ijk volume_dim);
long get_edge_ind(long_arr la, short * data, int cutoff);

void fill_in_ratio(long edge_ind, long_arr la, float * ratio_data, xyz voxel_dim, ijk volume_dim);
void calculate_rr(long voxel, long seed, short * data, float * ratio_data, xyz voxel_dim, ijk volume_dim, int cutoff);
void calculate_face_rr(long seed, short * data, float * ratio_data, xyz voxel_dim, ijk volume_dim, int cutoff, int face);
float * calculate_all_rr(long seed, short * data, xyz voxel_dim, ijk volume_dim, int cutoff);

#endif