## This file contains two functions, they work together to:
##  input a matrix, output the inverse of the matrix, where the inversed matrix is cached when it is
##  first read in, and if there is a subsequent call for it, the matrix will not be re-read in,
##  instead the already-cached matrix will be used. This is to save time when the matrix is very large.

## Example usage:
##  > mat <- matrix(stats::rnorm(9),3,3)
##  > useMat <- makeCacheMatrix(mat)
##  > cacheSolve(useMat)   ## if this is run a second time, it gets the cached version of the matrix



## This function creates a matrix in a different environment, it is essentially caching the matrix
##  you input to it.

makeCacheMatrix <- function(x = matrix()) {
        m <- NULL                   # reset to null each time, otherwise below it stores mat
        set <- function(y) {
                x <<- y             # the <<- operator assigns a value to an object in an environment 
                m <<- NULL          #  that is different from the current environment
        }

        #  note these next three functions are not run when makeCacheMatrix is called.
        #   instead, they will be used by cacheSolve() to get values for x or for
        #   m (mat) and for setting the matrix.  These are usually called object 'methods'
        
        get <- function() { x }     # this function returns the value of the original matrix
        
        setmat <- function(mat)     # this is called by cacheSolve() during the first cacheSolve()
                { m <<- mat }       #  access and it will store the value using superassignment
        
        getmat <- function() { m }  # this will return the cached value to cacheSolve() on subsequent accesses

        # Added these lines -->
#         message("In the setmat() now...")
#         message("...(i) Environment for mat: (this is a temporary environment)")
#         print(where("mat"))
#         message("...(ii) Environment for m:")
#         print(where("m"))
#         message("...(iii) Environment for parent of mat:")
#         print(parent.env(where("mat")))
#         message("Are (ii) and (iii) equal? Yes!")
        
        list(set = set, get = get,
             setmat = setmat,
             getmat = getmat)
}


## This returns inverse of a matrix, it will first check if there is a cache of the (inversed) matrix, 
##  if it finds one, it will use it rather than run the solve() function on the original matrix again.

cacheSolve <- function(x, ...) {
        ## Return a matrix that is the inverse of 'x'
        m <- x$getmat()   # start here, if it exists, stop and return it (it is already inversed)
        if(!is.null(m)) {
                message("getting cached data")
                return(m) #stops function execution and returns m as a value
        }
        data <- x$get()   # this will execute if the matrix was not found in the getmat() function
        m <- solve(data)  # get inverse of the matrix
        x$setmat(m)       # set the inversed matrix, so subsequent pulls can use the cached version
        m
}



