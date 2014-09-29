#ifndef UNIT_TESTS_H
#define UNIT_TESTS_H

int report_xyz_to_ijk(xyz a, xyz voxel_dim, ijk should_be)
{
    ijk result = xyz_to_ijk(a, voxel_dim);

    printf("Coords (%.3f,%.3f,%.3f) should have ", a.x, a.y, a.z);
    printf("indices (%d, %d, %d)\n", should_be.i, should_be.j, should_be.k);
    printf("Test result is (%d, %d, %d)\n", result.i, result.j, result.k);
    printf(" ---> ");
    int all_good = (should_be.i == result.i) && (should_be.j == result.j) && 
                   (should_be.k == result.k);
    if (all_good) {
        printf("PASS\n");
    }
    else {
        printf("FAIL\n");
    }
    return all_good;
}

int report_ijk_to_ind(ijk a, ijk volume_dim, long should_be)
{
    long ind = ijk_to_ind(a, volume_dim);

    printf("Indices (%d, %d, %d) ", a.i, a.j, a.k);
    printf("should have index: %ld\n", should_be);
    printf("Test result is: %ld\n", ind);
    printf(" ---> ");
    if (ind == should_be) {
        printf("PASS\n");
    }
    else {
        printf("FAIL\n");
    }
    return (ind == should_be);
}

int report_ind_to_ijk(long ind, ijk volume_dim, ijk should_be)
{
    ijk test_result = ind_to_ijk(ind, volume_dim);
    printf("Index %ld should have index ",ind);
    printf("(%d, %d, %d)\n", should_be.i, should_be.j, should_be.k);
    printf("Test result is: ");
    printf("(%d, %d, %d)\n", test_result.i, test_result.j, test_result.k);
    printf(" ---> ");
    int all_correct = (should_be.i == test_result.i) && 
                      (should_be.j == test_result.j) &&
                      (should_be.k == test_result.k);
    if (all_correct) {
        printf("PASS\n");
    }
    else {
        printf("FAIL\n");
    }
    return all_correct;
}

int test_xyz_to_ijk()
{
    int p_all = 1;

    printf("Testing: xyz_to_ijk()\n");
    xyz voxel_dim = {1,1,1};

    printf("^^ Testing with voxel size %.1f x %.1f x %.1f\n", voxel_dim.x, 
           voxel_dim.y, voxel_dim.z);

    printf("-- Subcase a\n");
    xyz a = {0.5, 0.5, 0.5};
    ijk b = {0,0,0};
    p_all = p_all & report_xyz_to_ijk(a, voxel_dim, b);

    printf("-- Subcase b\n");
    a = (xyz){2.3, 1.1, 3.9};
    b = (ijk){2,1,3};
    p_all = p_all & report_xyz_to_ijk(a, voxel_dim, b);

    printf("-- Subcase c\n");
    a = (xyz){2, 1, 3};
    b = (ijk){1,0,2};
    p_all = p_all & report_xyz_to_ijk(a, voxel_dim, b);

    return p_all;
}

int test_ijk_to_ind()
{
    int p_all = 1;

    printf("Testing: ijk_to_ind()\n");

    ijk volume_dim = {3,3,3};

    printf("^^ Testing on a volume of size %d x %d x %d\n", volume_dim.i, 
           volume_dim.j, volume_dim.k);


    ijk a = {0,0,0};
    long ind = 0;
    printf("-- Subcase a\n");
    p_all = p_all & report_ijk_to_ind(a, volume_dim, ind);
    p_all = p_all & report_ind_to_ijk(ind, volume_dim, a);

    a = (ijk){2,2,2};
    ind = 26;
    printf("-- Subcase b\n");
    p_all = p_all & report_ijk_to_ind(a, volume_dim, ind);
    p_all = p_all & report_ind_to_ijk(ind, volume_dim, a);

    a = (ijk){1,0,0};
    ind = 1;
    printf("-- Subcase c\n");
    p_all = p_all & report_ijk_to_ind(a, volume_dim, ind);
    p_all = p_all & report_ind_to_ijk(ind, volume_dim, a);

    a = (ijk){0,2,0};
    ind = 6;
    printf("-- Subcase d\n");
    p_all = p_all & report_ijk_to_ind(a, volume_dim, ind);
    p_all = p_all & report_ind_to_ijk(ind, volume_dim, a);

    a = (ijk){0,0,2};
    ind = 18;
    printf("-- Subcase e\n");
    p_all = p_all & report_ijk_to_ind(a, volume_dim, ind);
    p_all = p_all & report_ind_to_ijk(ind, volume_dim, a);

    a = (ijk){2,0,1};
    ind = 11;
    printf("-- Subcase f\n");
    p_all = p_all & report_ijk_to_ind(a, volume_dim, ind);
    p_all = p_all & report_ind_to_ijk(ind, volume_dim, a);

    volume_dim = (ijk){3,4,5};
    printf("^^ Testing on a volume of size %d x %d x %d\n", volume_dim.i, 
           volume_dim.j, volume_dim.k);

    a = (ijk){1,3,3};
    ind = 46;
    printf("-- Subcase a\n");
    p_all = p_all & report_ijk_to_ind(a, volume_dim, ind);
    p_all = p_all & report_ind_to_ijk(ind, volume_dim, a);

    return p_all;
}

int unit_tests()
{
    int p_all = 1;
    p_all = p_all & test_ijk_to_ind();
    p_all = p_all & test_xyz_to_ijk();

    printf("Passed all unit tests ---> ");
    if (p_all) {
        printf("PASSED ALL\n");
    }
    else {
        printf("FAILED AT LEAST ONE\n");
    }
    return 0;
}

#endif