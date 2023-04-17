// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "./MintCertificate.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Course is Ownable {
   
    //teacher = 0x52D08dC9881520fc50bbb3960ca8751A124778DC
    //student = 0x51e2e71858d90D6823E8013605aADcD91Ce051c8

    string public name; //How to build Dapps on BNB Chain
    uint public enrollmentDeadline; //1682771295 = Saturday, 29 April 2023 12:28:15
    mapping(address => bool) public teachers;
    mapping(address => bool) public enrolledStudents;
    mapping(address => bool) public passedStudents;
    mapping(address => uint) public studentRatings; 

    struct Application {
        string content; // IPFS hash of the application content
        uint256 date; // timestamp of the application date
        bool accepted; // whether the application is accepted or not
        address teacher; // address of the teacher who accepted the application
    }

    address public minterAddress; // address of the contract that mints SBT certificate
    string public ipfsHash; // IPFS hash of the assignment content
    uint256 public deadline; // timestamp of the assignment deadline
    mapping(address => Application) public applications; // mapping of student addresses to their applications

    event NewApplication(address indexed student, string content, uint256 date);
    event ApplicationAccepted(address indexed student, address indexed teacher, uint256 date);
    event ApplicationRejected(address indexed student, uint256 date);


    constructor(
        string memory _name, 
        uint _enrollmentDeadline,
        address _minterAddress,
        string memory _ipfsHash, 
        uint256 _deadline) {
        name = _name;
        enrollmentDeadline = _enrollmentDeadline;
        minterAddress = _minterAddress; 
        ipfsHash = _ipfsHash; //QmTv2mhyakBPkSz2CmjeSVGNtVmUnYgdi7aVaFyJTRF2rj
        deadline = _deadline; // 1681993695 = Thursday, 20 April 2023 12:28:15
    }

    function addTeacher(address _teacher) public onlyOwner {
        teachers[_teacher] = true;
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
        require(teachers[msg.sender], "Only the teacher can set the rating");
        require(enrolledStudents[_student], "Student is not enrolled in the course");
        require(!passedStudents[_student], "Student has already passed the course");

        studentRatings[_student] = _rating;
    }

    function getRating(address _student) public view returns (uint) {
        require(enrolledStudents[_student], "Student is not enrolled in the course");
        require(!passedStudents[_student], "Student has already passed the course");

        return studentRatings[_student];
    }

    //student's homework: QmaS1ckkt9nd738iqnhH59ismouYkRpyk9UrZAxTLc3qXe
    function submitApplication(string memory _content) public {
        require(block.timestamp <= deadline, "Application deadline has passed");
        require(enrolledStudents[msg.sender], "Student is not enrolled in the course");
        require(!passedStudents[msg.sender], "Student has already passed the course");

        Application storage application = applications[msg.sender];
        require(bytes(application.content).length == 0, "Student has already applied");

        application.content = _content;
        application.date = block.timestamp;

        emit NewApplication(msg.sender, _content, block.timestamp);
    }

    function acceptApplication(address _student) public {
        require(teachers[msg.sender], "Only the course teacher can accept applications");

        Application storage application = applications[_student];
        require(bytes(application.content).length != 0, "Student has not applied");
        require(!application.accepted, "Student's application has already been accepted");

        application.accepted = true;
        application.teacher = msg.sender;

        emit ApplicationAccepted(_student, msg.sender, block.timestamp);
    }

    function rejectApplication(address _student) public {
        require(teachers[msg.sender], "Only the course teacher can reject applications");

        Application storage application = applications[_student];
        require(bytes(application.content).length != 0, "Student has not applied");
        require(!application.accepted, "Student's application has already been accepted");

        delete applications[_student];

        emit ApplicationRejected(_student, block.timestamp);
    }

        function rate(address _student, uint256 _rating) public {
        require(teachers[msg.sender], "Only the course teacher can rate solutions");

        // Ensure the student has submitted an application and it has been accepted
        Application storage application = applications[_student];
        require(bytes(application.content).length != 0, "Student has not submitted an application");
        require(application.accepted, "Student's application has not been accepted");

        // Store the rating for the student
        setRating(_student, _rating);
    }
     
    // Mint an SBT certificate for the student
    //tokenURI = 'ipfs://QmYC1T7RrUfWwySz2bpwPRtxySVznJCgKCkoB3XMikbKSH/1.png';
    //tokenURI = 'ipfs://QmYC1T7RrUfWwySz2bpwPRtxySVznJCgKCkoB3XMikbKSH/2.png';
    //tokenURI = 'ipfs://QmYC1T7RrUfWwySz2bpwPRtxySVznJCgKCkoB3XMikbKSH/3.png';
    // ipfs://QmTv2mhyakBPkSz2CmjeSVGNtVmUnYgdi7aVaFyJTRF2rj/HowToDapp.png
    function mintCertificate(address to, string memory tokenURI) public {
        require(!passedStudents[msg.sender], 
                       "Student has not passed the course");

        MintCertificate certificate = MintCertificate(minterAddress);
        certificate.safeMint(to, tokenURI);
    }
}
