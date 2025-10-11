import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String selectedDay = "Monday";
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  // Sample timetable data
  final Map<String, List<Map<String, String>>> schedule = {
    "Monday": [
      {
        "time": "04:00 PM - 05:30 PM",
        "subject": "Mathematics",
        "teacher": "Mr. Rajesh Kumar",
        "batch": "Batch A",
        "room": "Room 101"
      },
      {
        "time": "06:00 PM - 07:30 PM",
        "subject": "Physics",
        "teacher": "Dr. Priya Sharma",
        "batch": "Batch A",
        "room": "Room 102"
      },
    ],
    "Tuesday": [
      {
        "time": "04:00 PM - 05:30 PM",
        "subject": "Chemistry",
        "teacher": "Mrs. Anjali Verma",
        "batch": "Batch A",
        "room": "Room 103"
      },
      {
        "time": "06:00 PM - 07:30 PM",
        "subject": "Biology",
        "teacher": "Dr. Amit Patel",
        "batch": "Batch A",
        "room": "Room 104"
      },
    ],
    "Wednesday": [
      {
        "time": "04:00 PM - 05:30 PM",
        "subject": "English",
        "teacher": "Ms. Kavita Das",
        "batch": "Batch A",
        "room": "Room 101"
      },
      {
        "time": "06:00 PM - 07:30 PM",
        "subject": "Mathematics",
        "teacher": "Mr. Rajesh Kumar",
        "batch": "Batch A",
        "room": "Room 101"
      },
    ],
    "Thursday": [
      {
        "time": "04:00 PM - 05:30 PM",
        "subject": "Physics",
        "teacher": "Dr. Priya Sharma",
        "batch": "Batch A",
        "room": "Room 102"
      },
      {
        "time": "06:00 PM - 07:30 PM",
        "subject": "Chemistry",
        "teacher": "Mrs. Anjali Verma",
        "batch": "Batch A",
        "room": "Room 103"
      },
    ],
    "Friday": [
      {
        "time": "04:00 PM - 05:30 PM",
        "subject": "Biology",
        "teacher": "Dr. Amit Patel",
        "batch": "Batch A",
        "room": "Room 104"
      },
      {
        "time": "06:00 PM - 07:30 PM",
        "subject": "English",
        "teacher": "Ms. Kavita Das",
        "batch": "Batch A",
        "room": "Room 101"
      },
    ],
    "Saturday": [
      {
        "time": "09:00 AM - 10:30 AM",
        "subject": "Mathematics",
        "teacher": "Mr. Rajesh Kumar",
        "batch": "Batch A",
        "room": "Room 101"
      },
      {
        "time": "11:00 AM - 12:30 PM",
        "subject": "Physics",
        "teacher": "Dr. Priya Sharma",
        "batch": "Batch A",
        "room": "Room 102"
      },
      {
        "time": "02:00 PM - 03:30 PM",
        "subject": "Chemistry",
        "teacher": "Mrs. Anjali Verma",
        "batch": "Batch A",
        "room": "Room 103"
      },
      {
        "time": "04:00 PM - 05:30 PM",
        "subject": "Biology",
        "teacher": "Dr. Amit Patel",
        "batch": "Batch A",
        "room": "Room 104"
      },
    ],
    "Sunday": [
      {
        "time": "09:00 AM - 10:30 AM",
        "subject": "Mathematics",
        "teacher": "Mr. Rajesh Kumar",
        "batch": "Batch B",
        "room": "Room 101"
      },
      {
        "time": "11:00 AM - 12:30 PM",
        "subject": "English",
        "teacher": "Ms. Kavita Das",
        "batch": "Batch B",
        "room": "Room 101"
      },
      {
        "time": "02:00 PM - 03:30 PM",
        "subject": "Physics",
        "teacher": "Dr. Priya Sharma",
        "batch": "Batch C",
        "room": "Room 102"
      },
      {
        "time": "04:00 PM - 05:30 PM",
        "subject": "Test Series",
        "teacher": "All Teachers",
        "batch": "All Batches",
        "room": "Hall A"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Class Schedule",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with current batch info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Your Batch: Batch A",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Grade 10 - Science Stream",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Day Selection
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedDay == days[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDay = days[index];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        days[index].substring(0, 3),
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Classes List
          Expanded(
            child: schedule[selectedDay] != null &&
                    schedule[selectedDay]!.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: schedule[selectedDay]!.length,
                    itemBuilder: (context, index) {
                      final classData = schedule[selectedDay]![index];
                      return ClassCard(
                        time: classData["time"]!,
                        subject: classData["subject"]!,
                        teacher: classData["teacher"]!,
                        batch: classData["batch"]!,
                        room: classData["room"]!,
                        color: _getSubjectColor(classData["subject"]!),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No classes scheduled",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case "mathematics":
        return const Color(0xFF3B82F6);
      case "physics":
        return const Color(0xFF8B5CF6);
      case "chemistry":
        return const Color(0xFFEC4899);
      case "biology":
        return const Color(0xFF10B981);
      case "english":
        return const Color(0xFFF59E0B);
      case "test series":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class ClassCard extends StatelessWidget {
  final String time;
  final String subject;
  final String teacher;
  final String batch;
  final String room;
  final Color color;

  const ClassCard({
    super.key,
    required this.time,
    required this.subject,
    required this.teacher,
    required this.batch,
    required this.room,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 6,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subject,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          batch,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          teacher,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.meeting_room_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        room,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}