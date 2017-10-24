module derelict.vlfeat;

import derelict.util.loader;

/**
    generic.h
*/

alias vl_size = size_t;
alias vl_type = int;
alias vl_uint32 = uint;

/**
    kmeans.h
*/

extern(System)
{

/** @brief K-means algorithms */

    enum VlKMeansAlgorithm
    {
        VlKMeansLloyd,       /**< Lloyd algorithm */
        VlKMeansElkan,       /**< Elkan algorithm */
        VlKMeansANN          /**< Approximate nearest neighbors */
    }

    /** @brief K-means initialization algorithms */

    enum VlKMeansInitialization
    {
        VlKMeansRandomSelection,  /**< Randomized selection */
        VlKMeansPlusPlus          /**< Plus plus raondomized selection */
    }

    /** ------------------------------------------------------------------
    ** @brief K-means quantizer
    **/

    struct VlKMeans
    {
        vl_type dataType ;                      /**< Data type. */
        vl_size dimension ;                     /**< Data dimensionality. */
        vl_size numCenters ;                    /**< Number of centers. */
        vl_size numTrees ;                      /**< Number of trees in forest when using ANN-kmeans. */
        vl_size maxNumComparisons ;             /**< Maximum number of comparisons when using ANN-kmeans. */

        VlKMeansInitialization initialization ; /**< Initalization algorithm. */
        VlKMeansAlgorithm algorithm ;           /**< Clustring algorithm. */
        VlVectorComparisonType distance ;       /**< Distance. */
        vl_size maxNumIterations ;              /**< Maximum number of refinement iterations. */
        double minEnergyVariation ;             /**< Minimum energy variation. */
        vl_size numRepetitions ;                /**< Number of clustering repetitions. */
        int verbosity ;                         /**< Verbosity level. */

        void * centers ;                        /**< Centers */
        void * centerDistances ;                /**< Centers inter-distances. */

        double energy ;                         /**< Current solution energy. */
        VlFloatVectorComparisonFunction floatVectorComparisonFn ;
        VlDoubleVectorComparisonFunction doubleVectorComparisonFn ;
    }
}

/**
    mathop.h
*/

extern(System)
{
    alias VlFloatVectorComparisonFunction = float *function(vl_size, const float *, const float *);
    alias VlDoubleVectorComparisonFunction = double *function(vl_size, const double *, const double *);

    enum VlVectorComparisonType
    {
        VlDistanceL1,        /**< l1 distance (squared intersection metric) */
        VlDistanceL2,        /**< squared l2 distance */
        VlDistanceChi2,      /**< squared Chi2 distance */
        VlDistanceHellinger, /**< squared Hellinger's distance */
        VlDistanceJS,        /**< squared Jensen-Shannon distance */
        VlDistanceMahalanobis,     /**< squared mahalanobis distance */
        VlKernelL1,          /**< intersection kernel */
        VlKernelL2,          /**< l2 kernel */
        VlKernelChi2,        /**< Chi2 kernel */
        VlKernelHellinger,   /**< Hellinger's kernel */
        VlKernelJS           /**< Jensen-Shannon kernel */
    }
}

/**
    sift.h
*/

/** @brief SIFT filter pixel type */
alias vl_sift_pix = float ;

/** ------------------------------------------------------------------
 ** @brief SIFT filter keypoint
 **
 ** This structure represent a keypoint as extracted by the SIFT
 ** filter ::VlSiftFilt.
 **/

extern(System)
{
    struct VlSiftKeypoint
    {
        int o ;           /**< o coordinate (octave). */

        int ix ;          /**< Integer unnormalized x coordinate. */
        int iy ;          /**< Integer unnormalized y coordinate. */
        int is_ ;          /**< Integer s coordinate. */

        float x ;     /**< x coordinate. */
        float y ;     /**< y coordinate. */
        float s ;     /**< s coordinate. */
        float sigma ; /**< scale. */
    }

    /** ------------------------------------------------------------------
    ** @brief SIFT filter
    **
    ** This filter implements the SIFT detector and descriptor.
    **/

    struct VlSiftFilt
    {
        double sigman ;       /**< nominal image smoothing. */
        double sigma0 ;       /**< smoothing of pyramid base. */
        double sigmak ;       /**< k-smoothing */
        double dsigma0 ;      /**< delta-smoothing. */

        int width ;           /**< image width. */
        int height ;          /**< image height. */
        int O ;               /**< number of octaves. */
        int S ;               /**< number of levels per octave. */
        int o_min ;           /**< minimum octave index. */
        int s_min ;           /**< minimum level index. */
        int s_max ;           /**< maximum level index. */
        int o_cur ;           /**< current octave. */

        vl_sift_pix *temp ;   /**< temporary pixel buffer. */
        vl_sift_pix *octave ; /**< current GSS data. */
        vl_sift_pix *dog ;    /**< current DoG data. */
        int octave_width ;    /**< current octave width. */
        int octave_height ;   /**< current octave height. */

        vl_sift_pix *gaussFilter ;  /**< current Gaussian filter */
        double gaussFilterSigma ;   /**< current Gaussian filter std */
        vl_size gaussFilterWidth ;  /**< current Gaussian filter width */

        VlSiftKeypoint* keys ;/**< detected keypoints. */
        int nkeys ;           /**< number of detected keypoints. */
        int keys_res ;        /**< size of the keys buffer. */

        double peak_thresh ;  /**< peak threshold. */
        double edge_thresh ;  /**< edge threshold. */
        double norm_thresh ;  /**< norm threshold. */
        double magnif ;       /**< magnification factor. */
        double windowSize ;   /**< size of Gaussian window (in spatial bins) */

        vl_sift_pix *grad ;   /**< GSS gradient data. */
        int grad_o ;          /**< GSS gradient data octave. */
    }
}

private
{
    import derelict.util.system;

    static if(Derelict_OS_Linux)
    {
        version(X86_64)
            enum libNames = "libvl.so";
        else
            static assert(0, "Need to implement VLFeat libNames for this arch.");
    }
    else
    {
        static assert(0, "Need to implement VLFeat libNames for this operating system.");
    }

    enum functionTypes = [
        //kmeans.h
        ["VlKMeans *", "vl_kmeans_new", "vl_type", "VlVectorComparisonType"],
        ["VlKMeans *", "vl_kmeans_new_copy", "const(VlKMeans) *"],
        ["void", "vl_kmeans_delete", "VlKMeans *"],
        ["void", "vl_kmeans_reset", "VlKMeans *"],
        ["double", "vl_kmeans_cluster", "VlKMeans *", "const void *", "vl_size", "vl_size", "vl_size"],
        ["void", "vl_kmeans_quantize", "VlKMeans *", "vl_uint32 *", "void *", "const void *", "vl_size"],
        ["void", "vl_kmeans_set_centers", "VlKMeans *", "const void *", "vl_size", "vl_size"],
        ["void", "vl_kmeans_init_centers_with_rand_data", "VlKMeans *", "const void *", "vl_size", "vl_size", "vl_size"],
        ["void", "vl_kmeans_init_centers_plus_plus", "VlKMeans *", "const void *", "vl_size", "vl_size", "vl_size"],
        ["double", "vl_kmeans_refine_centers", "VlKMeans *", "const void *", "vl_size"],

        //sift.h
        ["VlSiftFilt*", "vl_sift_new", "int", "int", "int", "int", "int"],
        ["void", "vl_sift_delete", "VlSiftFilt *"],
        ["int", "vl_sift_process_first_octave", "VlSiftFilt *", "const vl_sift_pix *"],
        ["int", "vl_sift_process_next_octave", "VlSiftFilt *"],
        ["void", "vl_sift_detect", "VlSiftFilt *"],
        ["int", "vl_sift_calc_keypoint_orientations", "VlSiftFilt *", "double[4]", "const VlSiftKeypoint *"],
        ["void", "vl_sift_calc_keypoint_descriptor", "VlSiftFilt *", "vl_sift_pix *", "const VlSiftKeypoint *", "double"],
        ["void", "vl_sift_calc_raw_descriptor", "const VlSiftFilt *", "const vl_sift_pix *", "vl_sift_pix *", "int", "int",
            "double", "double", "double", "double"],
        ["void", "vl_sift_keypoint_init", "const VlSiftFilt *", "VlSiftKeypoint *", "double", "double", "double"]
    ];

    string generateFunctionAliases()
    {
        import std.algorithm : joiner;
        import std.conv : to;

        string ret;

        foreach(ft; functionTypes)
        {
            ret ~= "alias da_" ~ ft[1] ~ " = " ~ ft[0] ~ " function(" ~ ft[2 .. $].joiner(",").to!string ~ ");";
        }

        return ret;
    }

    string generateFunctionPointers()
    {
        string ret;

        foreach(ft; functionTypes)
        {
            ret ~= "da_" ~ ft[1] ~ " " ~ ft[1] ~ ";";
        }

        return ret;
    }

    string generateFunctionBinds()
    {
        string ret;

        foreach(ft; functionTypes)
        {
            ret ~= "bindFunc(cast(void**)&" ~ ft[1] ~ ", \"" ~ ft[1] ~ "\");";
        }

        return ret;
    }
}

extern(System) @nogc nothrow
{
    mixin(generateFunctionAliases());
}

__gshared
{
    mixin(generateFunctionPointers());
}

class DerelictVLFeatLoader : SharedLibLoader
{
    public
    {
        this()
        {
            super(libNames);
        }
    }

    protected
    {
        override void loadSymbols()
        {
            mixin(generateFunctionBinds());
        }
    }
}

__gshared DerelictVLFeatLoader DerelictVLFeat;

shared static this()
{
    DerelictVLFeat = new DerelictVLFeatLoader();
}

unittest
{
    DerelictVLFeat.load();
}