// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./Course.sol";

contract Assignment {
    address public courseAddress; // address of the course contract that created this assignment
    string public ipfsHash; // IPFS hash of the assignment content
    uint256 public deadline; // timestamp of the assignment deadline

    constructor(
        address _courseAddress,
        string memory _ipfsHash,
        uint256 _deadline
    ) {
        courseAddress = _courseAddress;
        ipfsHash = _ipfsHash;
        deadline = _deadline;
    }

    function submitApplicationEncodedState(
        string memory contentIpfsHash,
        uint256 applicationTimestamp,
        address student
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    courseAddress,
                    ipfsHash,
                    deadline,
                    student,
                    contentIpfsHash,
                    applicationTimestamp
                )
            );
    }

    function rateApplicationEncodedState(
        string memory contentIpfsHash,
        uint256 applicationTimestamp,
        address student,
        address teacher,
        uint256 rating
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    submitApplicationEncodedState(
                        contentIpfsHash,
                        applicationTimestamp,
                        student
                    ),
                    teacher,
                    rating
                )
            );
    }

    function rateApplicationState(
        string memory contentIpfsHash,
        uint256 applicationTimestamp,
        address student,
        address teacher,
        uint256 rating
    ) internal view returns (bytes32) {
        return
            ECDSA.toEthSignedMessageHash(
                rateApplicationEncodedState(
                    contentIpfsHash,
                    applicationTimestamp,
                    student,
                    teacher,
                    rating
                )
            );
    }

    event ApplicationPassed(
        address indexed student,
        address indexed teacher,
        string assignmentTextIpfs,
        string applicationTextIpfs,
        uint256 deadlineTimestamp,
        uint256 applicationTimestamp,
        uint256 rating
    );

    function saveAplicationRating(
        string memory contentIpfsHash,
        uint256 applicationTimestamp,
        address student,
        address teacher,
        uint256 rating,
        bytes calldata studentSignature,
        bytes calldata teacherSignature
    ) public {
        require(
            deadline >= applicationTimestamp,
            "Assignment deadline has passed"
        );
        require(
            Course(courseAddress).isEnrolled(student),
            "Student is not enrolled in the course"
        );
        require(rating >= 0 && rating <= 10, "Rationg should be from 0 to 10");
        require(
            Course(courseAddress).teacher() == teacher,
            "Not authorized teacher"
        );

        bytes32 messageHash = rateApplicationState(
            contentIpfsHash,
            applicationTimestamp,
            student,
            teacher,
            rating
        );

        require(
            ECDSA.recover(messageHash, studentSignature) == student,
            "Invalid student signature"
        );
        require(
            ECDSA.recover(messageHash, teacherSignature) == teacher,
            "Invalid teacher signature"
        );

        emit ApplicationPassed(
            student,
            teacher,
            ipfsHash,
            contentIpfsHash,
            deadline,
            applicationTimestamp,
            rating
        );
    }
}
