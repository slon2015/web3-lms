// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "./Course.sol";

contract Assignment {
    struct Application {
        string content; // IPFS hash of the application content
        uint256 date; // timestamp of the application date
        bool accepted; // whether the application is accepted or not
        address teacher; // address of the teacher who accepted the application
    }

    address public courseAddress; // address of the course contract that created this assignment
    string public ipfsHash; // IPFS hash of the assignment content
    uint256 public deadline; // timestamp of the assignment deadline
    mapping(address => Application) public applications; // mapping of student addresses to their applications

    event NewApplication(address indexed student, string content, uint256 date);
    event ApplicationAccepted(address indexed student, address indexed teacher, uint256 date);
    event ApplicationRejected(address indexed student, uint256 date);

    constructor(address _courseAddress, string memory _ipfsHash, uint256 _deadline) {
        courseAddress = _courseAddress;
        ipfsHash = _ipfsHash;
        deadline = _deadline;
    }

    function submitApplication(string memory _content) public {
        require(block.timestamp <= deadline, "Application deadline has passed");
        require(Course(courseAddress).isEnrolled(msg.sender), "Student is not enrolled in the course");
        require(!Course(courseAddress).hasPassed(msg.sender), "Student has already passed the course");

        Application storage application = applications[msg.sender];
        require(bytes(application.content).length == 0, "Student has already applied");

        application.content = _content;
        application.date = block.timestamp;

        emit NewApplication(msg.sender, _content, block.timestamp);
    }

    function acceptApplication(address _student) public {
        require(msg.sender == Course(courseAddress).teacher(), "Only the course teacher can accept applications");

        Application storage application = applications[_student];
        require(bytes(application.content).length != 0, "Student has not applied");
        require(!application.accepted, "Student's application has already been accepted");

        application.accepted = true;
        application.teacher = msg.sender;

        emit ApplicationAccepted(_student, msg.sender, block.timestamp);
    }

    function rejectApplication(address _student) public {
        require(msg.sender == Course(courseAddress).teacher(), "Only the course teacher can reject applications");

        Application storage application = applications[_student];
        require(bytes(application.content).length != 0, "Student has not applied");
        require(!application.accepted, "Student's application has already been accepted");

        delete applications[_student];

        emit ApplicationRejected(_student, block.timestamp);
    }

    function rate(address _student, uint256 _rating) public {
        require(msg.sender == Course(courseAddress).teacher(), "Only the course teacher can rate solutions");

        // Ensure the student has submitted an application and it has been accepted
        Application storage application = applications[_student];
        require(bytes(application.content).length != 0, "Student has not submitted an application");
        require(application.accepted, "Student's application has not been accepted");

        // Store the rating for the student
        Course(courseAddress).setRating(_student, _rating);
    }
}
