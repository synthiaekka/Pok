// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProofOfKnowledge {
    struct Student {
        uint256 id;
        string name;
        uint256 points;
        address wallet;
    }

    struct Certificate {
        uint256 id;
        string courseName;
        address issuedTo;
        uint256 issueDate;
        bool isValid;
    }

    struct Challenge {
        uint256 id;
        string description;
        uint256 rewardPoints;
        bool isActive;
        address winner;
    }

    uint256 public nextStudentId;
    uint256 public nextCertificateId;
    uint256 public nextChallengeId;

    mapping(uint256 => Student) public students;
    mapping(uint256 => Certificate) public certificates;
    mapping(uint256 => Challenge) public challenges;

    event StudentRegistered(uint256 studentId, string name, address wallet);
    event CertificateIssued(uint256 certificateId, string courseName, address issuedTo);
    event ChallengeCreated(uint256 challengeId, string description);
    event ChallengeCompleted(uint256 challengeId, address winner);

    function registerStudent(string memory _name) public {
        nextStudentId++;
        students[nextStudentId] = Student(nextStudentId, _name, 0, msg.sender);
        emit StudentRegistered(nextStudentId, _name, msg.sender);
    }

    function issueCertificate(uint256 _studentId, string memory _courseName) public {
        require(students[_studentId].wallet != address(0), "Student does not exist");

        nextCertificateId++;
        certificates[nextCertificateId] = Certificate(nextCertificateId, _courseName, students[_studentId].wallet, block.timestamp, true);

        emit CertificateIssued(nextCertificateId, _courseName, students[_studentId].wallet);
    }

    function createChallenge(string memory _description, uint256 _rewardPoints) public {
        nextChallengeId++;
        challenges[nextChallengeId] = Challenge(nextChallengeId, _description, _rewardPoints, true, address(0));

        emit ChallengeCreated(nextChallengeId, _description);
    }

    function completeChallenge(uint256 _challengeId, uint256 _studentId) public {
        Challenge storage challenge = challenges[_challengeId];
        require(challenge.isActive, "Challenge is not active");
        require(students[_studentId].wallet != address(0), "Student does not exist");

        challenge.isActive = false;
        challenge.winner = students[_studentId].wallet;

        students[_studentId].points += challenge.rewardPoints;

        emit ChallengeCompleted(_challengeId, students[_studentId].wallet);
    }

    function verifyCertificate(uint256 _certificateId) public view returns (bool) {
        return certificates[_certificateId].isValid;
    }
}
