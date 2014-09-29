#include "matrix_ops.h"

double get_min_side(xyz a)
{
    double min1 = a.x <= a.y ? a.x : a.y;
    double min2 = min1 <= a.z ? min1 : a.z;
    return min2;
}

int get_sum_sides(ijk a)
{
    int this_sum = a.i + a.j + a.k;
    return this_sum;
}

double get_distance(xyz a, xyz b)
{
    double x_diff = a.x - b.x;
    double y_diff = a.y - b.y;
    double z_diff = a.z - b.z;
    double dist = sqrt(x_diff*x_diff + y_diff*y_diff + z_diff*z_diff);
    return dist;
}

double get_distance_one(xyz a) 
{
    double dist = sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
    return dist;
}

/*  From a to b */
xyz get_unit_vector(xyz a, xyz b)
{
    double dist = get_distance(a, b);
    xyz unit_vector;
    unit_vector.x = (b.x - a.x)/dist;
    unit_vector.y = (b.y - a.y)/dist;
    unit_vector.z = (b.z - a.z)/dist;
    return unit_vector;
}

xyz get_unit_vector_one(xyz a)
{
    double dist = get_distance_one(a);
    xyz unit_vector;
    unit_vector.x = a.x/dist;
    unit_vector.y = a.y/dist;
    unit_vector.z = a.z/dist;
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

long xyz_to_ind(xyz a, xyz voxel_dim, ijk volume_dim)
{
    ijk b = xyz_to_ijk(a, voxel_dim);
    long ind = ijk_to_ind(b, volume_dim);
    return ind;
}

xyz ind_to_xyz(long ind, xyz voxel_dim, ijk volume_dim)
{
    ijk a = ind_to_ijk(ind, volume_dim);
    xyz b = ijk_to_xyz(a, voxel_dim);
    return b;
}

int add_ind(long ind, long * r_inds, int r_inds_size)
{
    printf("Array address in function: %p\n", r_inds);

    if (r_inds_size == 0) {
        r_inds[r_inds_size] = ind;
        r_inds_size++;
        printf("Adding first index: %ld\n", ind);
    } 
    else {
        long last_ind = r_inds[r_inds_size - 1];
        if (last_ind != ind) {
            r_inds[r_inds_size] = ind;
            r_inds_size++;
            printf("Adding at next index, %d, the index %ld\n", r_inds_size, ind);
        }
    }
    return r_inds_size;
}

int is_inside_vol(xyz a, xyz voxel_dim, ijk volume_dim)
{
    double min_x = 0;
    double min_y = 0;
    double min_z = 0;
    double max_x = voxel_dim.x * volume_dim.i;
    double max_y = voxel_dim.y * volume_dim.j;
    double max_z = voxel_dim.z * volume_dim.k;

    if (a.x >= min_x && a.x <= max_x && a.y >= min_y && a.y <= max_y && 
        a.z >= min_z && a.z <= max_z) {
        return 1;
    }
    else {
        return 0;
    }
}

long_arr get_radius_inds(long voxel, long seed, xyz voxel_dim, ijk volume_dim)
{
    xyz v = ind_to_xyz(voxel, voxel_dim, volume_dim);
    xyz s = ind_to_xyz(seed, voxel_dim, volume_dim);
    xyz unit_vec = get_unit_vector(s,v);
    printf("Unit vec (%.2f, %.2f, %.2f)\n", unit_vec.x, unit_vec.y, unit_vec.z);

    double min_side = get_min_side(voxel_dim);
    double scale_factor = 0.25;
    xyz diff;
    diff.x = unit_vec.x * min_side * scale_factor;
    diff.y = unit_vec.y * min_side * scale_factor;
    diff.z = unit_vec.z * min_side * scale_factor;
    
    int sum_sides = get_sum_sides(volume_dim);
    long * r_inds = malloc(sum_sides * sizeof *r_inds);
    int r_inds_size = 0;

    int safety = 10000;
    xyz cur_xyz = s;
    int inside_vol = is_inside_vol(cur_xyz, voxel_dim, volume_dim);
    while(inside_vol && safety)
    {
        printf("Array address: %p\n", r_inds);

        long cur_ind = xyz_to_ind(cur_xyz, voxel_dim, volume_dim);
        r_inds_size = add_ind(cur_ind, r_inds, r_inds_size);

        printf("Most recent entry: %ld\n", r_inds[r_inds_size]);

        cur_xyz.x += diff.x;
        cur_xyz.y += diff.y;
        cur_xyz.z += diff.z;
        inside_vol = is_inside_vol(cur_xyz, voxel_dim, volume_dim);

        for (int i = 0; i < r_inds_size; i++)
        {
            printf("At end of while loop, [%d] = %ld\n", i,r_inds[i]);
        }

        safety--;
    }

    long_arr la;
    la.ptr = r_inds;
    la.size = r_inds_size;
    return la;
}