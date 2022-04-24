// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract SmartLearn {
  /*
   * Constant variables
   */
  
  // Punishment period in seconds
  uint constant PUNISHMENT_TIME = 30 days;

  /*
   * State variables
   */
  
  // Contract owner
  address owner;

  struct Task {
    string description;
    uint createdAt;
    uint value;
    uint dueDate;
    bool completed;
    bool cleared;
  }

  // Tasks
  mapping (address => Task[]) public tasks;

  // Credits
  mapping (address => uint) public credits;

  // Prizes
  mapping (address => uint) public prizes;

  /* 
   * Events
   */

  // Task added event
  event LogAdd (address userAddress, uint taskID); // TODO

  /* 
   * Modifiers
   */

  modifier isOwner (address _address) {
    require(msg.sender == owner);
    _;
  }

  modifier validDueDate (uint _date) {
    require(_date > block.timestamp);
    _;
  }

  // If task has not any prize locked in it
  modifier notPrized (uint _id) {
    require(!hasPrize(_id));
    _;
  }

  modifier completed (uint _id) {
    require(getTask(_id).completed);
    _;
  }

  modifier incompleted (uint _id) {
    require(!getTask(_id).completed);
    _;
  }



  constructor() {
    owner = msg.sender;
  }



  // Add task
  function add(string memory _description, uint _dueDate) public {
    Task memory task = Task({
      description: _description,
      createdAt: block.timestamp,
      value: 0,
      dueDate: _dueDate,
      completed: false,
      cleared: true
    });
    tasks[msg.sender].push(task);
  }


  // Update task
  function update(uint _taskID, string memory _description, uint _dueDate)
  public notPrized(_taskID) {
    Task memory task = tasks[msg.sender][_taskID];
    task.description = _description;
    task.dueDate = _dueDate;
    replace(_taskID, task);
  }
  

  // Set complete
  function setComplete(uint _id) public incompleted(_id) {
    Task memory task = getTask(_id);
    if (!hasPrize(_id) || !isExpired(_id)) {
      task.completed = true;
      replace(_id, task);
    }
  }

  // Set incomplete
  function setIncomplete(uint _id) public completed(_id) notPrized(_id) {
    Task memory task = getTask(_id);
    task.completed = false;
    replace(_id, task);
  }

  // Is task locked: Has no price locked in it
  function hasPrize(uint _id) internal view returns (bool) {
    return !(getTask(_id).value == 0);
  }

  // Is task overdue
  function isExpired(uint _id) internal view returns (bool) {
    Task memory task = getTask(_id);
    if (task.dueDate == 0) {
      return false;
    }
    return (task.dueDate < block.timestamp);
  }

  // Get current user tasks
  function getTasks() public view returns(Task[] memory) {
    return tasks[msg.sender];
  }

  // Get task
  function getTask(uint _id) public view returns(Task memory) {
    return tasks[msg.sender][_id];
  }


  // Replace task
  function replace(uint _id, Task memory _task) internal {
    tasks[msg.sender][_id] = _task;
  }

}
