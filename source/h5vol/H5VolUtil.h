#ifndef H5VL_UTIL
#define H5VL_UTIL

#include <adios2_c.h>
#include <hdf5.h>

#define H5VL_CODE_SUCC 1
#define H5VL_CODE_FAIL 0

static hid_t gUtilHDF5Type(adios2_type adios2Type)
{
    if (adios2Type == adios2_type_int8_t)
        return H5T_NATIVE_INT8;
    if (adios2Type == adios2_type_int16_t)
        return H5T_NATIVE_INT16;
    if (adios2Type == adios2_type_int32_t)
        return H5T_NATIVE_INT32;
    if (adios2Type == adios2_type_int64_t)
        return H5T_NATIVE_INT64;
    if (adios2Type == adios2_type_uint8_t)
        return H5T_NATIVE_UINT8;
    if (adios2Type == adios2_type_uint16_t)
        return H5T_NATIVE_UINT16;
    if (adios2Type == adios2_type_uint32_t)
        return H5T_NATIVE_UINT32;
    if (adios2Type == adios2_type_uint64_t)
        return H5T_NATIVE_UINT64;

    if (adios2Type == adios2_type_float)
        return H5T_NATIVE_FLOAT;

    if (adios2Type == adios2_type_double)
        return H5T_NATIVE_DOUBLE;

    if (adios2Type == adios2_type_long_double)
        return H5T_NATIVE_LDOUBLE;

    if (adios2Type == adios2_type_string)
    {
        hid_t string_t_id = H5Tcopy(H5T_C_S1);
        H5Tset_size(string_t_id,
                    30); // limiting each string to be less than 30 char long
        return string_t_id;
    }

    // unknown types
    return -1;
}

static adios2_type gUtilADIOS2Type(hid_t h5Type)
{
    if (H5Tequal(H5T_NATIVE_INT8, h5Type))
        return adios2_type_int8_t;

    if (H5Tequal(H5T_NATIVE_INT16, h5Type))
        return adios2_type_int16_t;

    if (H5Tequal(H5T_NATIVE_INT32, h5Type))
        return adios2_type_int32_t;

    if (H5Tequal(H5T_NATIVE_INT64, h5Type))
        return adios2_type_int64_t;

    if (H5Tequal(H5T_NATIVE_UINT8, h5Type))
        return adios2_type_uint8_t;

    if (H5Tequal(H5T_NATIVE_UINT16, h5Type))
        return adios2_type_uint16_t;

    if (H5Tequal(H5T_NATIVE_UINT32, h5Type))
        return adios2_type_uint32_t;

    if (H5Tequal(H5T_NATIVE_UINT64, h5Type))
        return adios2_type_uint64_t;

    if (H5Tequal(H5T_NATIVE_FLOAT, h5Type))
        return adios2_type_float;

    if (H5Tequal(H5T_NATIVE_DOUBLE, h5Type))
        return adios2_type_double;

    if (H5Tequal(H5T_NATIVE_LDOUBLE, h5Type))
        return adios2_type_long_double;

    if (H5Tget_class(h5Type) == H5T_NATIVE_CHAR)
        return adios2_type_string;

    if (H5Tget_class(h5Type) == H5T_STRING)
        return adios2_type_string;

    if (H5Tget_class(h5Type) == H5T_ENUM) //
        return adios2_type_uint8_t;
    // complex types are not supported in adios2_types
    // so return unknown
    return adios2_type_unknown;
}

/*
int gUtilADIOS2IsNone(hid_t space_id)
{
// note: using npts is better than type
// for example, the following line will get type SIMPLE instead of NON
// memspace = H5Screate_simple(DIM, count, NULL); H5Sselect_none(memspace);

  hsize_t npts = H5Sget_select_npoints(space_id);
  H5S_class_t stype = H5Sget_simple_extent_type(space_id);
  printf(" type = %d npts=%ld\n", stype, npts);
  if (0 == npts)
    return H5VL_CODE_SUCC;
  if ((H5S_NULL == stype) || (H5S_NO_CLASS == stype))
    return H5VL_CODE_SUCC;

  return H5VL_CODE_FAIL;
}
*/

static int gUtilADIOS2IsScalar(hid_t space_id)
{
    H5S_class_t stype = H5Sget_simple_extent_type(space_id);

    if (H5S_SCALAR == stype)
        return H5VL_CODE_SUCC;

    return H5VL_CODE_FAIL;
}

static int gUtilADIOS2GetDim(hid_t space_id)
{
    return H5Sget_simple_extent_ndims(space_id);
}

//
// h5 uses hsize_t for dimensions (unsigned long long)
// adios uses size_t
//
static void gUtilConvert(hsize_t *fromH5, size_t *to, uint ndims)
{
    uint i = 0;
    for (i = 0; i < ndims; i++)
    {
        to[i] = fromH5[i];
    }
}

static int gUtilADIOS2GetShape(hid_t space_id, size_t *shape, uint ndims)
{
    if (gUtilADIOS2IsScalar(space_id))
    {
        // nothing to do
        return H5VL_CODE_SUCC;
    }

    // get num dimensions
    hsize_t h5Shape[ndims];
    H5Sget_simple_extent_dims(space_id, h5Shape, NULL);

    gUtilConvert(h5Shape, shape, ndims);
    return H5VL_CODE_SUCC;
}

static int gUtilADIOS2GetBlockInfo(hid_t hyperSlab_id, size_t *start,
                                   size_t *count, hsize_t ndims)
{
    hsize_t npts = H5Sget_select_npoints(hyperSlab_id);

    if (0 == npts)
        return npts;
    else
    {
        hsize_t s[ndims], e[ndims];

        H5Sget_select_bounds(hyperSlab_id, s, e);

        hsize_t numElements = 1;
        hsize_t k = 0;
        for (k = 0; k < ndims; k++)
        {
            start[k] = s[k];
            count[k] = (e[k] - s[k]) + 1;
            numElements *= count[k];
        }

        if (npts == numElements)
            return npts; // ok got block
    }
    return H5VL_CODE_FAIL; // slab has many blocks

    /*
      NOTE: this is a well wish segment.  Reality is hdf5 returns numBlocks =
  numPts; 1 pt per block. so cann't apply this method!! hsize_t  numBlocks =
  H5Sget_select_hyper_nblocks(hyperSlab_id); REQUIRE_SUCC_MSG((1  == numBlocks),
  H5VL_CODE_FAIL, "Currently not able to support strides != 1 %ld", numBlocks);

  // now numBlocks = 1
  hsize_t *blockinfo = (hsize_t *)SAFE_MALLOC(sizeof(hsize_t) * 2 * ndims *
  numBlocks); herr_t status = H5Sget_select_hyper_blocklist(hyperSlab_id,
  (hsize_t)0, numBlocks, blockinfo);

  int i=0;
  for (i = 0; i < ndims; i++) {
    start[i] = blockinfo[i];
    count[i] = blockinfo[ndims + i] - start[i] + 1;
  }
    */
}

#endif
