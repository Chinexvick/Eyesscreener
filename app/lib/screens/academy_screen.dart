import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/academy_data.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/kit.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final app = context.watch<AppState>();
    final done = app.lessonsDone.length;
    final total = AcademyData.totalLessons;
    final gloss = AcademyData.glossary
        .where(
          (g) =>
              _q.isEmpty ||
              g.$1.toLowerCase().contains(_q.toLowerCase()) ||
              g.$2.toLowerCase().contains(_q.toLowerCase()),
        )
        .toList();

    return Scaffold(
      body: EyesBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const PageTitle(
                'Crypto Academy',
                subtitle:
                    'Short lessons that make you a safer, sharper researcher.',
                back: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 62,
                        height: 62,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 62,
                              height: 62,
                              child: CircularProgressIndicator(
                                value: done / total,
                                strokeWidth: 7,
                                strokeCap: StrokeCap.round,
                                backgroundColor: p.line,
                                valueColor: const AlwaysStoppedAnimation(
                                  Brand.green,
                                ),
                              ),
                            ),
                            Text(
                              '${(done / total * 100).round()}%',
                              style: inter(14, w: 800),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$done of $total lessons complete',
                              style: inter(15.5, w: 700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              done == total
                                  ? 'Well done, you finished everything!'
                                  : 'Keep going, a few minutes a day adds up.',
                              style: inter(13, color: p.dim, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SectionTitle(
                'Courses',
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              ),
              for (final c in AcademyData.courses)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _CourseCard(course: c),
                ),
              SectionTitle(
                'Glossary',
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.line),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _q = v),
                    style: inter(15, w: 500),
                    cursorColor: Brand.yellow,
                    decoration: InputDecoration(
                      hintText: 'Search terms',
                      hintStyle: inter(14.5, color: p.faint),
                      prefixIcon: Icon(Icons.search_rounded, color: p.faint),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: gloss.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            'No matching terms.',
                            style: inter(14, color: p.dim),
                          ),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < gloss.length; i++)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: i == gloss.length - 1
                                      ? null
                                      : Border(
                                          bottom: BorderSide(color: p.line),
                                        ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gloss[i].$1,
                                      style: inter(14.5, w: 700),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      gloss[i].$2,
                                      style: inter(
                                        13.5,
                                        color: p.dim,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final n = [
      for (var i = 0; i < course.lessons.length; i++)
        if (app.lessonDone('${course.id}:$i')) i,
    ].length;
    return Tap(
      onTap: () => openPage(context, CourseScreen(course: course)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: course.colors,
          ),
          boxShadow: [
            BoxShadow(
              color: course.colors.first.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    course.level.toUpperCase(),
                    style: inter(10.5, w: 800, color: Colors.white, spacing: 1),
                  ),
                ),
                const Spacer(),
                Icon(
                  course.icon,
                  color: Colors.white.withValues(alpha: 0.92),
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(course.title, style: display(21, color: Colors.white)),
            const SizedBox(height: 6),
            Text(
              course.blurb,
              style: inter(
                13.5,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: n / course.lessons.length,
                minHeight: 6,
                backgroundColor: Colors.black.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${course.lessons.length} lessons · ${course.minutes} min',
                  style: inter(
                    12.5,
                    w: 600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const Spacer(),
                Text(
                  n == course.lessons.length
                      ? 'Review'
                      : (n > 0 ? 'Continue' : 'Start'),
                  style: inter(13, w: 800, color: Colors.white),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key, required this.course});
  final Course course;

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  int? _open;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    final i = List.generate(widget.course.lessons.length, (i) => i).firstWhere(
      (i) => !app.lessonDone('${widget.course.id}:$i'),
      orElse: () => 0,
    );
    _open = i;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final app = context.watch<AppState>();
    final c = widget.course;
    return Scaffold(
      body: EyesBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              PageTitle(c.title, subtitle: c.blurb, back: true),
              for (var i = 0; i < c.lessons.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Tap(
                          onTap: () =>
                              setState(() => _open = _open == i ? null : i),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Tap(
                                  onTap: () {
                                    app.toggleLesson('${c.id}:$i');
                                    if (app.lessonDone('${c.id}:$i')) {
                                      showToast(context, 'Lesson complete');
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: app.lessonDone('${c.id}:$i')
                                          ? Brand.green
                                          : p.card2,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: app.lessonDone('${c.id}:$i')
                                            ? Brand.green
                                            : p.line,
                                      ),
                                    ),
                                    child: app.lessonDone('${c.id}:$i')
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 19,
                                            color: Colors.white,
                                          )
                                        : Text(
                                            '${i + 1}',
                                            style: inter(
                                              13,
                                              w: 700,
                                              color: p.dim,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.lessons[i].title,
                                        style: inter(15, w: 650),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${c.lessons[i].minutes} min read',
                                        style: inter(12.5, color: p.faint),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: _open == i ? 0.25 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: p.faint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _open == i
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox(width: double.infinity),
                          secondChild: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(color: p.line, height: 1),
                                const SizedBox(height: 14),
                                Text(
                                  c.lessons[i].body,
                                  style: inter(
                                    14.5,
                                    color: p.dim,
                                    height: 1.65,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                app.lessonDone('${c.id}:$i')
                                    ? GhostButton(
                                        label: 'Mark as not done',
                                        height: 46,
                                        onTap: () =>
                                            app.toggleLesson('${c.id}:$i'),
                                      )
                                    : PrimaryButton(
                                        label: 'Mark complete',
                                        icon: Icons.check_rounded,
                                        height: 48,
                                        onTap: () {
                                          app.toggleLesson('${c.id}:$i');
                                          showToast(context, 'Lesson complete');
                                          if (i < c.lessons.length - 1) {
                                            setState(() => _open = i + 1);
                                          }
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
