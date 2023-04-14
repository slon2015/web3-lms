// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

contract Course {
    address public teacher;
    string public name;
    uint public enrollmentDeadline;
    mapping(address => bool) public enrolledStudents;

    constructor(
        address _teacher,
        string memory _name,
        uint _enrollmentDeadline
    ) {
        teacher = _teacher;
        name = _name;
        enrollmentDeadline = _enrollmentDeadline;
    }

    function enroll(address student) external {
        require(
            block.timestamp <= enrollmentDeadline,
            "Enrollment deadline has passed"
        );
        require(!enrolledStudents[student], "Already enrolled in the course");

        enrolledStudents[student] = true;
    }

    function isEnrolled(address student) public view returns (bool) {
        return enrolledStudents[student];
    }
}
