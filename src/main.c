/* -----------------------------------------------------------------------------
 *
 *
 *
 *
 *

gcc -Wall -o bin/edgerr src/main.c src/matrix_ops.c \
    -Iinc -Llib -lniftiio -lznz -lz -lm

 *
 *
 *
 *
 *
 * -----------------------------------------------------------------------------
 */


#include <stdio.h>
#include <nifti1_io.h>
#include "matrix_ops.h"

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

int main(int argc, char * argv[])
{
    nifti_image * nim = NULL;
    char * fin = NULL;
    char * fout = NULL;
    long seed = -1;
    int cutoff = 1;
    int verbose = 0;
    int ac = 0;

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
            verbose = atoi(argv[ac]);
            nifti_set_debug_level(verbose);
        }
        else if( !strncmp(argv[ac], "-s", 2) ){
            if( ++ac >= argc ){
                fprintf(stderr, "** missing argument for -seed\n");
                return 1;
            }
            seed = atol(argv[ac]);
        }
        else if( !strncmp(argv[ac], "-cut", 4)) {
            if (++ac >= argc) {
                fprintf(stderr, "** missing argument for -cutoff\n");
                return 1;
            }
            cutoff = atoi(argv[ac]);
        }
        else{
            fprintf(stderr,"** invalid option, '%s'\n", argv[ac]);
            return 1;
        }
    }

    if( !fin  ) {fprintf(stderr, "** missing option '-input'\n"); return 1;}
    if( !fout ) {fprintf(stderr, "** missing option '-output'\n"); return 1;}
    if( seed < 0 ) {fprintf(stderr, "** missing option '-seed'\n"); return 1;}

    /* read input dataset */
    nim = nifti_image_read(fin, 1);
    if ( !nim ) {
        fprintf(stderr, "** failed to read NIFTI image from '%s'", fin);
        return 1;
    }

    printf("Nifti image cal_min=%f\n", nim->cal_min);
    printf("Nifti image cal_max=%f\n", nim->cal_max);
    printf("Nifti scl_slope=%f\n", nim->scl_slope);
    printf("Nifti scl_inter=%f\n", nim->scl_inter); 
    printf("Nifti descrip=\'%s\'\n", nim->descrip);
    printf("Nifti aux_file=\'%s\'\n", nim->aux_file);

    /*
    short * data = nim->data;
    xyz voxel_dim = (xyz){nim->dx, nim->dy, nim->dz};
    ijk volume_dim = (ijk){nim->nx, nim->ny, nim-> nz};
    float * rr = calculate_all_rr(seed, data, voxel_dim, volume_dim, cutoff);

    free(nim->data);
    nim->nbyper = 4;
    nim->datatype = 16;
    float * minmax = get_min_max(rr, nim->nvox);
    nim->cal_min = minmax[0];
    nim->cal_max = minmax[1];
    nim->data = rr;
    free(minmax);
    */

    /* assign nifti_image fname/iname pair, based on output filename
      (request to 'check' image and 'set_byte_order' here) */
    /*if( nifti_set_filenames(nim, fout, 1, 1) ) return 1;*/

    /* if we get here, write the output dataset */
    /*nifti_image_write( nim );*/

    /* and clean up memory */
    nifti_image_free( nim );

    return 0;

    /* memory clean up */
    nifti_image_free( nim );

    return 0;
}