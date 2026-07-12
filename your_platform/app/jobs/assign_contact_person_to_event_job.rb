# Assigns the contact person to the event in the background to save
# time in the request that creates the event.
# (Replaces the former `Event.delay.assign_contact_person_to_event`:
# sidekiq 6 dropped the delay extension.)
#
class AssignContactPersonToEventJob < ApplicationJob
  queue_as :default

  def perform(event_id, contact_person_id)
    Event.assign_contact_person_to_event event_id, contact_person_id
  end
end
