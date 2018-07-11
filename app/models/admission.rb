class Admission < ApplicationRecord
    belongs_to :user
    belongs_to :chat_room, counter_cache: true
    
    after_commit :user_join_chat_room_notification, on: :create
    after_commit :user_exit_chat_room_notification, on: :destroy
    
    
    def user_join_chat_room_notification
        # 요소를 추가하는 반응은 반드시 트리거를 통해서만 진행한다.
        Pusher.trigger("chat_room_#{self.chat_room_id}", 'join', self.as_json.merge({email: self.user.email}))
        Pusher.trigger("chat_room", 'join', self.chat_room.as_json)
    end
    
    def user_exit_chat_room_notification
        Pusher.trigger("chat_room_#{self.chat_room_id}", 'Exit', self.as_json.merge({email: self.user.email}))
        Pusher.trigger("chat_room", 'exit', self.chat_room.as_json)
    end
    
end
