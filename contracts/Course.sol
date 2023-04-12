// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

contract Course {
    address public teacher;
    string public name;
    uint public enrollmentDeadline;
    mapping(address => bool) public enrolledStudents;
    mapping(address => bool) public passedStudents;
    mapping(address => uint) public studentRatings; 


    constructor(address _teacher, string memory _name, uint _enrollmentDeadline) {
        teacher = _teacher;
        name = _name;
        enrollmentDeadline = _enrollmentDeadline;
    }

    function enroll(address student) external {
        require(block.timestamp <= enrollmentDeadline, "Enrollment deadline has passed");
        require(!enrolledStudents[student], "Already enrolled in the course");
        
        enrolledStudents[student] = true;
    }

    function isEnrolled(address student) public view returns (bool) {
        return enrolledStudents[student];
    }

    function hasPassed(address _student) public view returns (bool) {
        return passedStudents[_student];
    } 
    
    function setRating(address _student, uint _rating) public {
        require(msg.sender == teacher, "Only the teacher can set the rating");
        require(enrolledStudents[_student], "Student is not enrolled in the course");
        require(!passedStudents[_student], "Student has already passed the course");

        studentRatings[_student] = _rating;
    }

    function getRating(address _student) public view returns (uint) {
        require(enrolledStudents[_student], "Student is not enrolled in the course");
        require(!passedStudents[_student], "Student has already passed the course");

        return studentRatings[_student];
    }
}
