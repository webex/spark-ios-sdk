// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Notifications from Locus
extension Notifications {
    struct Locus {
        static let NotificationKey                    = "locus.notification.key"
        static let ParticipantJoined                  = "locus.participant_joined"
        static let ParticipantLeft                    = "locus.participant_left"
        static let ParticipantDeclined                = "locus.participant_declined"
        static let ParticipantAlerted                 = "locus.participant_alerted"
        static let ParticipantUpdated                 = "locus.participant_updated"
        static let ParticipantRolesUpdated            = "locus.participant_roles_updated"
        static let ParticipantControlsUpdated         = "locus.participant_controls_updated"
        static let ParticipantAudioMuted              = "locus.participant_audio_muted"
        static let ParticipantAudioUnmuted            = "locus.participant_audio_unmuted"
        static let ParticipantVideoMuted              = "locus.participant_video_muted"
        static let ParticipantVideoUnmuted            = "locus.participant_video_unmuted"
        static let ParticipantBroadcast               = "locus.participant_broadcast"
        static let ParticipantAudioConnectionCreated  = "locus.participant_audio_connection_created"
        static let ParticipantVideoConnectionCreated  = "locus.participant_video_connection_created"
        static let ParticipantMediaConnectionModified = "locus.participant_media_connection_modified"
        static let SelfChanged                        = "locus.self_changed"
        static let FloorGranted                       = "locus.floor_granted"
        static let FloorReleased                      = "locus.floor_released"
        static let SpaceUsersModified                 = "locus.space_users_modified"
        static let ControlsUpdated                    = "locus.controls_updated"
    }
}