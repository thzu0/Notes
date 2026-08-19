import '../features/notes/model/model.dart';

final List<Note> fakeNotes = [
  // ─────────────────────────────
  // Reminder / Checklist
  // ─────────────────────────────
  Note(
    id: '1',
    title: 'Reminder',
    content: '',
    type: NoteType.reminder,
    createdAt: DateTime(2026, 1, 17),
    checklistItems: [
      ChecklistItem(title: 'Explore Design', isDone: true),
      ChecklistItem(title: 'Kotlin', isDone: true),
      ChecklistItem(title: 'Learn 3D Model'),
      ChecklistItem(title: 'Design Shots'),
      ChecklistItem(title: 'Buy Groceries'),
      ChecklistItem(title: 'Call Mom'),
    ],
    imageUrl: '',
    checklistitems: [],
  ),

  // ─────────────────────────────
  // Quote
  // ─────────────────────────────
  Note(
    id: '2',
    title: 'Quote Today',
    content:
        'The best preparation for tomorrow is doing your best today.Today was one of those days when everything seemed to move at the right pace. I started my morning with a simple plan: finish the tasks I had been postponing, spend some time learning something new, and leave enough time in the evening to relax. At first, I thought the list was too long, but once I started, each task became easier than I expected.',
    type: NoteType.quote,
    createdAt: DateTime(2026, 1, 21),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  // ─────────────────────────────
  // Image Note
  // ─────────────────────────────
  Note(
    id: '3',
    title: 'Kuta Beach',
    content:
        'I stayed here for a big family vacation. This is a great affordable hotel to stay in Bali...',
    type: NoteType.image,
    createdAt: DateTime(2025, 12, 24),
    imageUrl: 'https://placehold.co/600x400/orange/white',
    checklistitems: [],
    checklistItems: [],
  ),

  // ─────────────────────────────
  // Target / Checklist (text first, then checkboxes)
  // ─────────────────────────────
  Note(
    id: '4',
    title: '2021 Hope',
    content: 'I have a dream that must come true !!!',
    type: NoteType.target,
    createdAt: DateTime(2026, 1, 21),
    checklistItems: [
      ChecklistItem(title: 'GPA above 3.60', isDone: true),
      ChecklistItem(title: 'Have a good job', isDone: true),
      ChecklistItem(title: 'Holidays in Japan'),
      ChecklistItem(title: 'Learn Flutter deeply'),
    ],
    imageUrl: '',
    checklistitems: [],
  ),

  // ─────────────────────────────
  // Text / Diary
  // ─────────────────────────────
  Note(
    id: '5',
    title: 'My Diary >,<',
    content:
        'Today was a really productive day. I worked on my projects and learned something new.',
    type: NoteType.diary,
    createdAt: DateTime(2026, 1, 20),
    imageUrl: '',
    checklistItems: [],
    checklistitems: [],
  ),

  // ─────────────────────────────
  // Another Text Note
  // ─────────────────────────────
  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),

  Note(
    id: '6',
    title: 'Statistika',
    content:
        'Data Science - an interdisciplinary field that uses scientific methods, processes and algorithms to extract knowledge from data.',
    type: NoteType.text,
    createdAt: DateTime(2026, 1, 19),
    imageUrl: '',
    checklistitems: [],
    checklistItems: [],
  ),
];
