#ifndef UNIT_TESTS_H
#define UNIT_TESTS_H

int report_xyz_to_ijk(xyz a, xyz voxel_dim, ijk should_be);
int report_ijk_to_ind(ijk a, ijk volume_dim, long should_be);
int report_ind_to_ijk(long ind, ijk volume_dim, ijk should_be);

int test_xyz_to_ijk();
int test_ijk_to_ind();

int unit_tests();

#endif