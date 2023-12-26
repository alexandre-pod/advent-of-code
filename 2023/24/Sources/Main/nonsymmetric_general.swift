//    /*
//     Copyright © 2023 Apple Inc.
//
//     Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//    Abstract:
//    Solver function for nonsymmetric general matrices.
//    */
//
//
//    import Accelerate
//
//    /// Returns the _x_ in _Ax = b_ for a nonsquare coefficient matrix using `sgesv_`.
//    ///
//    /// - Parameter a: The matrix _A_ in _Ax = b_ that contains `dimension * dimension`
//    /// elements.
//    /// - Parameter dimension: The order of matrix _A_.
//    /// - Parameter b: The matrix _b_ in _Ax = b_ that contains `dimension * rightHandSideCount`
//    /// elements.
//    /// - Parameter rightHandSideCount: The number of columns in _b_.
//    ///
//    /// The function specifies the leading dimension (the increment between successive columns of a matrix)
//    /// of matrices as their number of rows.
//
//    /// - Tag: nonsymmetric_general
//    func nonsymmetric_general(a: [Float],
//                              dimension: Int,
//                              b: [Float],
//                              rightHandSideCount: Int) -> [Float]? {
//        
//        var info: __LAPACK_int = 0
//        
//        /// Create a mutable copy of the right hand side matrix _b_ that the function returns as the solution matrix _x_.
//        var x = b
//        
//        /// Create a mutable copy of `a` to pass to the LAPACK routine. The routine overwrites `mutableA`
//        /// with the factors `L` and `U` from the factorization `A = P * L * U`.
//        var mutableA = a
//        
//        var ipiv = [__LAPACK_int](repeating: 0, count: dimension)
//        
//        /// Call `sgesv_` to compute the solution.
//        withUnsafePointer(to: __LAPACK_int(dimension)) { n in
//            withUnsafePointer(to: __LAPACK_int(rightHandSideCount)) { nrhs in
//                sgesv_(n,
//                       nrhs,
//                       &mutableA,
//                       n,
//                       &ipiv,
//                       &x,
//                       n,
//                       &info)
//            }
//        }
//        
//        if info != 0 {
//            NSLog("nonsymmetric_general error \(info)")
//            return nil
//        }
//        return x
//    }
