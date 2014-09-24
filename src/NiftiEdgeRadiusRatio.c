/* -----------------------------------------------------------------------------
 *
 *
 *
 * gcc -o edgerr NiftiEdgeRadiusRatio.c -I../include -L../lib \
 *     -lniftiio -lznz -lz -lm
 *
 *
 *
 *
 *
 * -----------------------------------------------------------------------------
 */


#include <stdio.h>
#include <nifti1_io.h>

int show_help(void)
{
    printf(
        "edgerr: compute the distance to the edge of the signal in an image\n"
        "\n"
        "    This program takes as input a seed voxel and then computes\n"
        "    at all other voxels the ratio of the (distance to the seed) and\n"
        "    the (distance to the edge) of the signal along the same radius.\n"
        "\n"
        "    basic usage: edgerr -input FILE_IN -output FILE_OUT -seed INDEX\n"
        "\n"
        "    options:     -help           : show this help\n"
        "                 -verb LEVEL     : the verbose level to LEVEL\n"
        "\n");
    return 0;
}

int calculate_edgerr(nifti_image * nim, long seed);

int main(int argc, char * argv[])
{
    nifti_image * nim = NULL;
    char        * fin = NULL;
    char        * fout = NULL;
    long          seed = -1;
    int           ac = 0;

    if( argc < 2 ){
        return show_help();
    }

    /* Process command line arguments */
    for( ac = 1; ac < argc; ac++ ){
        if( !strncmp(argv[ac], "-h", 2) ){
            return show_help();
        }
        else if( !strncmp(argv[ac], "-in", 3) ){
            if( ++ac >= argc ){
                fprintf(stderr, "** missing argument for -input\n");
                return 1;
            }
            fin = argv[ac];  /* no string copy, just pointer assignment */
        }
        else if( !strncmp(argv[ac], "-out", 4) ){
            if( ++ac >= argc ){
                fprintf(stderr, "** missing argument for -output\n");
                return 1;
            }
            fout = argv[ac];
        }
        else if( !strncmp(argv[ac], "-v", 2) ){
            if( ++ac >= argc ){
                fprintf(stderr, "** missing argument for -verb\n");
                return 1;
            }
            nifti_set_debug_level(atoi(argv[ac]));
        }
        else if( !strncmp(argv[ac], "-s", 2) ){
            if( ++ac >= argc ){
                fprintf(stderr, "** missing argument for -seed\n");
                return 1;
            }
            seed = atol(argv[ac]);
        }
        else{
            fprintf(stderr,"** invalid option, '%s'\n", argv[ac]);
            return 1;
        }
    }

    printf("Results from the parsing:\n");
    printf("%10s","FILE_IN:");
    printf(" %-30s\n",fin);
    printf("%10s","FILE_OUT:");
    printf(" %-30s\n",fout);
    printf("%10s","INDEX:");
    printf(" %-30ld\n",seed);

    if( !fin  )   {fprintf(stderr, "** missing option '-input'\n");  return 1;}
    if( !fout )   {fprintf(stderr, "** missing option '-output'\n"); return 1;}
    if( seed < 0 ){fprintf(stderr, "** missing option '-seed'\n");   return 1;}

    /* read input dataset */
    nim = nifti_image_read(fin, 1);
    if ( !nim ){
        fprintf(stderr, "** failed to read NIFTI image from '%s'", fin);
        return 1;
    }

    calculate_edgerr(nim, seed);

    /* memory clean up */
    nifti_image_free( nim );

    return 0;
}


/*
Potential problems: need to understand size_t better


*/
int calculate_edgerr(nifti_image * nim, long seed) {
    int nx = 0;
    int ny = 0;
    int nz = 0;
    int nt = 0;
    long nvox = 0;

    size_t nvox_t = 0;


    long nvox_l = (long)nvox_t;
    int size = sizeof(nvox_t);
    int size_l = sizeof(nvox_l);

    float dx = 0;
    float dy = 0;
    float dz = 0;

    int datatype = 0;
    short * data = NULL;

    nx = nim->nx;
    ny = nim->ny;
    nz = nim->nz;
    nt = nim->nt;
    dx = nim->dx;
    dy = nim->dy;
    dz = nim->dz;
    datatype = nim->datatype;
    nvox = nx*ny*nz;

    data = nim->data;
    short seed_data = data[seed];

    printf("Results from the reading NIFTI HEADER:\n");
    printf("%10s","nx:");
    printf(" %-30d\n",nx);
    printf("%10s","ny:");
    printf(" %-30d\n",ny);
    printf("%10s","nz:");
    printf(" %-30d\n",nz);
    printf("%10s","nt:");
    printf(" %-30d\n",nt);
    printf("%10s","dx:");
    printf(" %-30f\n",dx);
    printf("%10s","dy:");
    printf(" %-30f\n",dy);
    printf("%10s","dz:");
    printf(" %-30f\n",dz);
    printf("%10s","Datatype:");
    printf(" %-30d\n",datatype);
    printf("%30s","Size of size_t:");
    printf(" %-30d\n",size);
    printf("%30s","Size of long:");
    printf(" %-30d\n",size_l);
    printf("%10s","nvox:");
    printf(" %-30ld\n",nvox);

    printf("Value at the seed:\n");
    printf("nim[%ld] is %d\n",seed,seed_data);

    float * mydata = malloc(10 * sizeof *data);
    printf("Size of float: %ld\n",sizeof(float));
    printf("Size of double: %ld\n",sizeof(double));
    free(mydata);

    printf("Initializing array\n");
    float * rr_array = malloc(nvox * sizeof *rr_array);
    for (long i = 0; i < nvox; i++){
        rr_array[i] = -1;
    }
    printf("Array initialized\n");

    free(rr_array);

    return 0;
}