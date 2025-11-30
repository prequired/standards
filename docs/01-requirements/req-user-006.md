---
id: "REQ-USER-006"
title: "Profile Photo/Avatar"
domain: "User Management"
status: draft
priority: low
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-USER-006: Profile Photo/Avatar

## Description

The system shall support profile photos for all users, with upload capability and fallback to generated avatars.

## Rationale

Profile photos humanize the platform, improve recognition in communications, and support team page functionality on the marketing site.

## Source

- **Stakeholder:** UX Team
- **Document:** User experience requirements

## Fit Criterion (Measurement)

- Photo upload completes in under 5 seconds
- Uploaded images are resized/optimized automatically
- Generated avatars display for users without photos

## Dependencies

- **Depends On:** REQ-USER-001 (staff profiles), REQ-USER-002 (client profiles)
- **Blocks:** None
- **External:** Media storage (S3), image processing service

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Users can upload profile photo (JPG, PNG, WebP)
2. Maximum file size enforced (5MB)
3. Images are automatically cropped to square
4. Multiple sizes generated (thumbnail, medium, large)
5. Fallback avatar generated from initials
6. Gravatar integration as secondary fallback
7. Photos imported from social login (optional)
8. Users can remove their photo

## Notes

- Use Spatie Media Library for Laravel
- Store on S3 with CloudFront CDN for performance

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
