library(pizzarr)

MockArray <- R6::R6Class("MockArray",
                         public = list(
                           shape = NULL,
                           chunks = NULL,
                           initialize = function(shape, chunks) {
                             self$shape <- shape
                             self$chunks <- chunks
                           },
                           get_shape = function() {
                             return(self$shape)
                           },
                           get_chunks = function() {
                             return(self$chunks)
                           }
                         )
)

test_that("basic indexer for array that spans multiple chunks", {
  z <- MockArray$new(shape = c(10, 10), chunks = c(5, 5))
  
  expect_equal(z$get_shape(), c(10, 10))
  expect_equal(z$get_chunks(), c(5, 5))
  
  # OrthogonalIndexer supports SliceDimIndexer
  bi <- OrthogonalIndexer$new(list(zb_slice(0, 11), zb_slice(0, 11)), z)
  expect_equal(as.numeric(bi$shape), c(10, 10))
  expect_equal(length(bi$dim_indexers), 2)
  expect_equal("SliceDimIndexer" %in% class(bi$dim_indexers[[1]]), TRUE)
  
  # combination of IntArrayDimIndexer and SliceDimIndexer
  bi <- OrthogonalIndexer$new(list(0:9, zb_slice(0, 11)), z)
  expect_equal("IntArrayDimIndexer" %in% class(bi$dim_indexers[[1]]), TRUE)
  expect_equal("SliceDimIndexer" %in% class(bi$dim_indexers[[2]]), TRUE)
  
  # unordered integer vector is a IntArrayDimIndexer
  bi <- OrthogonalIndexer$new(list(0:9, c(2,3,5,4,1)), z)
  expect_equal("IntArrayDimIndexer" %in% class(bi$dim_indexers[[2]]), TRUE)
  
  # empty dimension is a slice
  bi <- OrthogonalIndexer$new(list(1), z)
  expect_equal("SliceDimIndexer" %in% class(bi$dim_indexers[[2]]), TRUE)
  
  # TODO: add tests for adding BoolArrayDimIndexer
})

test_that("basic indexer for array that spans multiple chunks where shape is not a multiple", {
  z <- MockArray$new(shape = c(10, 10), chunks = c(3, 3))
  
  expect_equal(z$get_shape(), c(10, 10))
  expect_equal(z$get_chunks(), c(3, 3))
  
  # OrthogonalIndexer supports SliceDimIndexer
  bi <- OrthogonalIndexer$new(list(zb_slice(0, 11), zb_slice(0, 11)), z)
  expect_equal(as.numeric(bi$shape), c(10, 10))
  expect_equal(length(bi$dim_indexers), 2)
  expect_equal("SliceDimIndexer" %in% class(bi$dim_indexers[[1]]), TRUE)
  
  # combination of IntArrayDimIndexer and SliceDimIndexer
  bi <- OrthogonalIndexer$new(list(0:9, zb_slice(0, 11)), z)
  expect_equal("IntArrayDimIndexer" %in% class(bi$dim_indexers[[1]]), TRUE)
  expect_equal("SliceDimIndexer" %in% class(bi$dim_indexers[[2]]), TRUE)
  
  # unordered integer vector is a IntArrayDimIndexer
  bi <- OrthogonalIndexer$new(list(0:9, c(2,3,5,4,1)), z)
  expect_equal("IntArrayDimIndexer" %in% class(bi$dim_indexers[[2]]), TRUE)
  
  # empty dimension is a slice
  bi <- OrthogonalIndexer$new(list(1), z)
  expect_equal("SliceDimIndexer" %in% class(bi$dim_indexers[[2]]), TRUE)
  
  # TODO: add tests for adding BoolArrayDimIndexer
})

test_that("int array dimension indexer", {
  
  # ordered int array index
  # iad <- IntArrayDimIndexer$new(1:10, 10, 3)
  iad <- IntArrayDimIndexer$new(0:9, 10, 3)
  expect_equal(iad$dim_sel, 0:9)
  expect_equal(iad$dim_chunk_ixs, c(1,2,3,4))
  expect_equal(iad$dim_len, 10)
  expect_equal(iad$dim_chunk_len, 3)
  expect_equal(iad$num_chunks, 4)
  expect_equal(iad$chunk_nitems, c(3,3,3,1))
  expect_equal(iad$order, 1)
  
  # unordered int array index
  iad <- IntArrayDimIndexer$new(c(2,3,5,1,2), 6, 3)
  expect_equal(iad$dim_sel, c(2,1,2,3,5))
  expect_equal(iad$dim_chunk_ixs, c(1,2))
  expect_equal(iad$dim_len, 6)
  expect_equal(iad$dim_chunk_len, 3)
  expect_equal(iad$num_chunks, 2)
  expect_equal(iad$chunk_nitems, c(3,2))
  expect_equal(iad$order, 3)
  
  # error for wrong dimension length
  expect_error(IntArrayDimIndexer$new(1:10, 6, 3))
  
  # missing chunk size
  expect_error(IntArrayDimIndexer$new(1:10, 10))
  
})

test_that("bool array dimension indexer", {
  
  # boolean checks
  expect_equal(is_bool(TRUE), TRUE)
  expect_equal(is_bool(1), FALSE)
  expect_equal(is_bool(1.2), FALSE)
  expect_equal(is_bool(c(TRUE, FALSE, TRUE)), FALSE)
  expect_equal(is_bool_vec(c(TRUE, FALSE, TRUE)), TRUE)
  expect_equal(is_bool_vec(c(TRUE, FALSE, 1)), FALSE)
  expect_equal(is_bool_vec(c(TRUE, 1.2, 1)), FALSE)
  expect_equal(is_bool_list(list(TRUE, FALSE, FALSE)), TRUE)
  expect_equal(is_bool_list(list(TRUE, 1.2, 1)), FALSE)
  expect_equal(is_bool_list(c(TRUE, FALSE, FALSE)), FALSE)
  
  # ordered int array index
  iad <- BoolArrayDimIndexer$new(c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE), 8, 5)
  expect_equal(iad$dim_sel, c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE))
  expect_equal(iad$dim_chunk_ixs, c(1,2))
  expect_equal(iad$dim_len, 8)
  expect_equal(iad$dim_chunk_len, 5)
  expect_equal(iad$num_chunks, 2)
  expect_equal(iad$chunk_nitems, c(3,2))
  
  # error for wrong dimension length
  expect_error(BoolArrayDimIndexer$new(c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE), 3, 5))
  
  # missing chunk size
  expect_error(BoolArrayDimIndexer$new(c(TRUE, TRUE, FALSE, TRUE, FALSE), 5))
  
})