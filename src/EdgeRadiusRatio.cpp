
int main(int argc, char * argv[])
{
    char * filename = 0;
    if (argc == 2)
    {
        filename = argv[argc - 1];
    }

    THD_3dim_dataset * dset = THD_open_dataset(filename);

    int dind = 0;

    volbase = (float *)DSET_ARRAY(dset, dind);
    int nx = DSET_NX(dset);
    int ny = DSET_NY(dset);
    int nz = DSET_NZ(dset);
}



