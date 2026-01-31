# Studyzee App Update Implementation Plan

## Overview
Comprehensive updates to Student, Teacher, Parent, and Admin modules with authentication flow improvements.

## Phase 1: Authentication & Role Flow ✓
### Single Login Screen
- [x] Current login already detects role from Firestore
- [x] Auto-directs to correct dashboard based on user role
- [x] Role selection UI exists but validates against Firestore role
- **Action**: Remove role selection UI and auto-detect role after login

## Phase 2: Admin Module Updates
### Send Notification
- [ ] Create admin notification screen
- [ ] Add dropdown with options: All users, Parents only, Individual classes
- [ ] Integrate with Firestore collections for users and classes
- [ ] Ensure notifications appear for students, parents, teachers based on role filters
- [ ] Maintain backward compatibility with existing notification collection

## Phase 3: Student Module Updates
### Attendance
- [ ] Remove "Leave" option from My Attendance UI
- [ ] Remove "Leave" from main Attendance section
- [ ] Remove related UI elements (buttons, filters, status displays)
- [ ] Remove state handling for leave status
- [ ] Clean up Firestore field references (keep data, just don't show)

### Notification Settings
- [ ] Remove "Notification Settings" option from student profile
- [ ] Remove related logic and preference checks

### Study Materials
- [ ] Filter study materials by logged-in student's assigned subjects
- [ ] Use existing Firestore class and subject mapping
- [ ] Show only relevant materials

### Exams
- [ ] Fix exam status mapping
- [ ] Move submitted/started exams to Upcoming list
- [ ] Update status logic to show correct exam state

## Phase 4: Teacher Module Updates
### Send Notification
- [ ] Fix user selection list for notifications
- [ ] Correct Firestore write logic
- [ ] Ensure same structure as admin notifications

## Phase 5: Parent Module Updates
### Overflow Issues
- [ ] Fix all overflow errors across parent screens
- [ ] Use Flexible containers, Expanded widgets
- [ ] Add SafeArea where needed
- [ ] Proper layout handling

### Notifications
- [ ] Remove all static notifications
- [ ] Pull notifications only from Firestore
- [ ] Ensure consistent UI with other roles

## Phase 6: Global Fixes
- [ ] Remove Notification Settings tab from all roles
- [ ] Remove all hardcoded static content
- [ ] Replace with Firestore-driven data
- [ ] Fix all layout overflow issues
- [ ] Ensure notification UI consistency across Student, Parent, Teacher roles
- [ ] Maintain existing design

## Implementation Order
1. Authentication flow simplification
2. Admin notification creation
3. Student module updates (attendance, notifications, study materials, exams)
4. Teacher notification fixes
5. Parent module fixes (overflow, notifications)
6. Global cleanup and testing

## Notes
- Maintain current Firestore structure where possible
- Update only affected paths
- Ensure backward compatibility
- Keep existing design intact
- Only update required logic and UI parts
