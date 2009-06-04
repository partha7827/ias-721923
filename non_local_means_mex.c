#include <math.h>
#include "mex.h"

#define max(a, b) (a>b)? a : b
#define min(a, b) (a<b)? a : b

double *noisy;
double *kernel;
int neig;
int win;
double h;
int width;
int heigth;
int frames;


double getKernelValue(int i, int j) {
    return kernel[i+j*(2*neig+1)];
}

double getN1Value(int i, int j, int m, int n) {
    return noisy[i+m+(j+n)*(heigth+2*neig)];
}

double getN2Value(int r, int c, int m, int n, int k) {
    int index = (r-neig+m)+(c-neig+n)*(heigth+2*neig) + k*(width+2*neig)*(heigth+2*neig);
    return noisy[index];
}


/**
 * NON_LOCAL_MEANS_MEX
 *   nl_image = non_local_means_mex(noisy, kernel, neig, win, h)
 *
 *   prhs[0] = noisy:     width+2*neig x heigth+2*neig x frames
 *   prhs[1] = kernel:    neig x neig
 *   prhs[2] = win:      scalar
 *   prhs[3] = neig:       scalar
 *   prhs[4] = h:         scalar
 *
 *   plhs[0] = nl_image:  width x heigth
 *
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    mwSize num_of_dims = mxGetNumberOfDimensions(prhs[0]);
    mwSize num_of_elem = mxGetNumberOfElements(prhs[0]);
    const mwSize *dims = mxGetDimensions(prhs[0]);
    
    double *nl_image;
    
    int i, j;
    int col_min, col_max, row_min, row_max;
    int r, c, m, n, k;
    double z, nl, mw, gwed, w;
    
    noisy = mxGetPr(prhs[0]);
    kernel = mxGetPr(prhs[1]);
    win = mxGetScalar(prhs[2]);
    neig = mxGetScalar(prhs[3]);
    h = mxGetScalar(prhs[4]);
    
    width = dims[1]-2*neig;
    heigth = dims[0]-2*neig;
    frames = (num_of_dims>2)? dims[2] : 1;
    
    plhs[0] = mxCreateDoubleMatrix(heigth, width, mxREAL);
    nl_image = mxGetPr(plhs[0]);
    
    //mexPrintf("%d x %d x %d = %d\n", dims[1], dims[0], frames, num_of_elem);
    
    for(i=0; i<heigth; i++) {
        for(j=0; j<width; j++) {
            
            // search window boundaries
            row_min = max(i+neig-win, neig);
            row_max = min(i+neig+win, neig+heigth-1);
            
            col_min = max(j+neig-win, neig);
            col_max = min(j+neig+win, neig+width-1);
            
            z = 0;
            nl = 0;
            mw = 0;
            
            // for each pixel in serch window
            for(r=row_min; r<=row_max; r++) {
                for(c=col_min; c<=col_max; c++) {
                    
                    // for each frame
                    for(k=0; k<frames; k++) {
                        
                        if(k!=0 || !(r==i+neig && c==j+neig)) {
                            gwed = 0;

                            // for each neighborhood in search window
                            for(m=0; m<=2*neig; m++) {
                                for(n=0; n<=2*neig; n++) {
                                    gwed += getKernelValue(m, n) * pow(getN1Value(i, j, m, n) - getN2Value(r, c, m, n, k), 2);
                                }
                            }

                            w = exp(-gwed / pow(h, 2));

                            if(w>mw) {
                                mw = w;
                            }

                            z = z + w;

                            nl = nl + w*noisy[r + c*(heigth+2*neig) + k*(width+2*neig)*(heigth+2*neig)];
                        }
                        
                    }
                    
                }
            }
            
            z = z + mw;
            
            nl = nl + mw*noisy[i+neig + (j+neig)*(heigth+2*neig)];
            
            nl_image[i+j*heigth] = nl / z;
            
        }
    }
}