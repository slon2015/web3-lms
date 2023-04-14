import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("User flow", () => {
  async function deployAssignment() {
    const [deployer, teacher, student, platform] = await ethers.getSigners();
    const CourseFactory = await ethers.getContractFactory("Course");
    const AssignmentFactory = await ethers.getContractFactory("Assignment");

    const course = await CourseFactory.deploy(
      teacher.address,
      "First group",
      new Date().getTime() + 10000000000
    );

    let tx = await course.enroll(student.address);
    await tx.wait();

    const assignment = await AssignmentFactory.deploy(
      course.address,
      "abcd",
      new Date().getTime() + 10000000000
    );

    return { course, assignment, teacher, student, platform };
  }

  it("Should pass", async () => {
    const { course, assignment, teacher, student, platform } =
      await loadFixture(deployAssignment);

    const contentHash = "contentHash";
    const applicationTimestamp = new Date().getTime();
    const rating = 8;

    const messageToSign = await assignment.rateApplicationEncodedState(
      contentHash,
      applicationTimestamp,
      student.address,
      teacher.address,
      rating
    );

    const studentSignature = await student.signMessage(
      ethers.utils.arrayify(messageToSign)
    );
    const teacherSignature = await teacher.signMessage(
      ethers.utils.arrayify(messageToSign)
    );

    const tx = await assignment.saveAplicationRating(
      contentHash,
      applicationTimestamp,
      student.address,
      teacher.address,
      rating,
      studentSignature,
      teacherSignature
    );

    const receipt = await tx.wait();

    expect(receipt.logs).length(1);
  });
});
