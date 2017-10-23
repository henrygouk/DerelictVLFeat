module derelict.vlfeat;

import derelict.util.loader;

alias vl_size = size_t;
alias vl_type = int;

/** @brief SIFT filter pixel type */
alias vl_sift_pix = float ;

/** ------------------------------------------------------------------
 ** @brief SIFT filter keypoint
 **
 ** This structure represent a keypoint as extracted by the SIFT
 ** filter ::VlSiftFilt.
 **/

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