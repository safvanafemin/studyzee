import 'package:flutter/material.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          "Classes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: "Recorded Classes"),
            Tab(text: "Live Classes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RecordedClassesTab(),
          LiveClassesTab(),
        ],
      ),
    );
  }
}

// Live Classes Tab
class LiveClassesTab extends StatelessWidget {
  const LiveClassesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final liveClasses = [
      {
        "subject": "Mathematics",
        "teacher": "Mr. Rajesh Kumar",
        "time": "4:00 PM - 5:30 PM",
        "batch": "Batch A",
        "status": "live",
        "participants": 45,
        "topic": "Quadratic Equations",
      },
      {
        "subject": "Physics",
        "teacher": "Dr. Priya Sharma",
        "time": "6:00 PM - 7:30 PM",
        "batch": "Batch A",
        "status": "upcoming",
        "participants": 0,
        "topic": "Newton's Laws of Motion",
      },
      {
        "subject": "Chemistry",
        "teacher": "Mrs. Anjali Verma",
        "time": "7:45 PM - 9:15 PM",
        "batch": "Batch B",
        "status": "upcoming",
        "participants": 0,
        "topic": "Chemical Bonding",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: liveClasses.length,
      itemBuilder: (context, index) {
        final classData = liveClasses[index];
        return LiveClassCard(
          subject: classData["subject"] as String,
          teacher: classData["teacher"] as String,
          time: classData["time"] as String,
          batch: classData["batch"] as String,
          status: classData["status"] as String,
          participants: classData["participants"] as int,
          topic: classData["topic"] as String,
        );
      },
    );
  }
}

// Recorded Classes Tab
class RecordedClassesTab extends StatefulWidget {
  const RecordedClassesTab({super.key});

  @override
  State<RecordedClassesTab> createState() => _RecordedClassesTabState();
}

class _RecordedClassesTabState extends State<RecordedClassesTab> {
  String selectedSubject = "All";
  final List<String> subjects = [
    "All",
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "English"
  ];

  final List<Map<String, dynamic>> recordedClasses = [
    {
      "subject": "Mathematics",
      "teacher": "Mr. Rajesh Kumar",
      "date": "Oct 03, 2025",
      "duration": "1h 30m",
      "topic": "Trigonometry - Part 2",
      "views": 128,
      "thumbnail": "math",
    },
    {
      "subject": "Physics",
      "teacher": "Dr. Priya Sharma",
      "date": "Oct 02, 2025",
      "duration": "1h 45m",
      "topic": "Electromagnetic Induction",
      "views": 95,
      "thumbnail": "physics",
    },
    {
      "subject": "Chemistry",
      "teacher": "Mrs. Anjali Verma",
      "date": "Oct 01, 2025",
      "duration": "1h 20m",
      "topic": "Organic Chemistry Basics",
      "views": 142,
      "thumbnail": "chemistry",
    },
    {
      "subject": "Biology",
      "teacher": "Dr. Amit Patel",
      "date": "Sep 30, 2025",
      "duration": "1h 15m",
      "topic": "Cell Division - Mitosis",
      "views": 87,
      "thumbnail": "biology",
    },
    {
      "subject": "English",
      "teacher": "Ms. Kavita Das",
      "date": "Sep 29, 2025",
      "duration": "1h 00m",
      "topic": "Essay Writing Techniques",
      "views": 63,
      "thumbnail": "english",
    },
    {
      "subject": "Mathematics",
      "teacher": "Mr. Rajesh Kumar",
      "date": "Sep 28, 2025",
      "duration": "1h 25m",
      "topic": "Calculus - Derivatives",
      "views": 156,
      "thumbnail": "math",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredClasses = selectedSubject == "All"
        ? recordedClasses
        : recordedClasses
            .where((cls) => cls["subject"] == selectedSubject)
            .toList();

    return Column(
      children: [
        // Subject Filter
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedSubject == subjects[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSubject = subjects[index];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      subjects[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
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

        // Recorded Classes List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredClasses.length,
            itemBuilder: (context, index) {
              final classData = filteredClasses[index];
              return RecordedClassCard(
                subject: classData["subject"] as String,
                teacher: classData["teacher"] as String,
                date: classData["date"] as String,
                duration: classData["duration"] as String,
                topic: classData["topic"] as String,
                views: classData["views"] as int,
                thumbnail: classData["thumbnail"] as String,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Live Class Card Widget
class LiveClassCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String time;
  final String batch;
  final String status;
  final int participants;
  final String topic;

  const LiveClassCard({
    super.key,
    required this.subject,
    required this.teacher,
    required this.time,
    required this.batch,
    required this.status,
    required this.participants,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    bool isLive = status == "live";
    Color subjectColor = _getSubjectColor(subject);

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
      child: Column(
        children: [
          Padding(
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
                          color: subjectColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isLive ? Colors.red : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLive ? "LIVE" : "UPCOMING",
                            style: TextStyle(
                              color: isLive ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  topic,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      teacher,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.group_outlined,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      batch,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (isLive) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        "$participants students watching",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLive ? Colors.red : subjectColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: InkWell(
              onTap: () {
                print("Join class: $subject");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLive ? Icons.play_circle_filled : Icons.schedule,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLive ? "Join Now" : "Set Reminder",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
      default:
        return const Color(0xFF6B7280);
    }
  }
}

// Recorded Class Card Widget
class RecordedClassCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String date;
  final String duration;
  final String topic;
  final int views;
  final String thumbnail;

  const RecordedClassCard({
    super.key,
    required this.subject,
    required this.teacher,
    required this.date,
    required this.duration,
    required this.topic,
    required this.views,
    required this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    Color subjectColor = _getSubjectColor(subject);

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
      child: InkWell(
        onTap: () {
          print("Play recorded class: $topic");
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Thumbnail
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    subjectColor,
                    subjectColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: subjectColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subject,
                          style: TextStyle(
                            color: subjectColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.visibility,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            "$views views",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
      default:
        return const Color(0xFF6B7280);
    }
  }
}