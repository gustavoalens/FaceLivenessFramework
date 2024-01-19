import ARKit

protocol FaceMovementRecognizerProtocol: FaceRecognizerProtocol {
    func didChanged(transform: FaceRotation)
}

extension FaceMovementRecognizerProtocol {
    func didChanged(faceAnchor: ARFaceAnchor) {
        didChanged(transform: getRotations(fromMatrix: faceAnchor.transform))
    }
    
    private func getRotations(fromMatrix matrix: matrix_float4x4) -> FaceRotation {
        // Get quaternions
        // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
        let qw = sqrt(1 + matrix.columns.0.x + matrix.columns.1.y + matrix.columns.2.z) / 2.0
        let qx = (matrix.columns.2.y - matrix.columns.1.z) / (qw * 4.0)
        let qy = (matrix.columns.0.z - matrix.columns.2.x) / (qw * 4.0)
        let qz = (matrix.columns.1.x - matrix.columns.0.y) / (qw * 4.0)
        
        // Deduce euler angles with some cosines
        // https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
        /// yaw (z-axis rotation)
        let siny = 2.0 * (qw * qz + qx * qy)
        let cosy = 1.0 - 2.0 * (qy * qy + qz * qz)
        let yaw = matrix.radiansToDegress(radians: atan2(siny, cosy))
        // pitch (y-axis rotation)
        let sinp = 2.0 * (qw * qy - qz * qx)
        var pitch: Float
        if abs(sinp) >= 1 {
            pitch = matrix.radiansToDegress(radians: copysign(Float.pi / 2, sinp))
        } else {
            pitch = matrix.radiansToDegress(radians: asin(sinp))
        }
        /// roll (x-axis rotation)
        let sinr = +2.0 * (qw * qx + qy * qz)
        let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
        let roll = matrix.radiansToDegress(radians: atan2(sinr, cosr))
        
        /// return array containing ypr values
        return FaceRotation(fromXAxis: roll, fromYAxis: pitch, fromZAxis: yaw)
    }
}
