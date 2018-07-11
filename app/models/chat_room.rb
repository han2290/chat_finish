class ChatRoom < ApplicationRecord
    has_many :admissions
    has_many :users, through: :admissions
    
    has_many :chats
    
    before_commit :destroy_chat_room_notification, on: :destroy
    
    after_commit :update_chat_room_notification, on: :update
    after_commit :create_chat_room_notification, on: :create
    # after_commit :master_admit_room, on: :create
    # ChatRoom이 하나 만들어 지고 나면 다음 메소드를 실행한다.
    # on 뒤에는 CRUD만 들어감
    
    def destroy_chat_room_notification
        Admission.where(chat_room_id: self.id).destroy_all
        self.chats.destroy_all
        Pusher.trigger("chat_room_#{self.id}",'destroy',{})
        Pusher.trigger('chat_room','destroy', self.as_json)
    end
    
    def update_chat_room_notification
        Pusher.trigger('chat_room', 'update', self.as_json)
    end
    
    def user_admit_room(user) # instance method
        # ChatRoom이 하나 만들어 지고 나면 다음 메소드를 실행한다.
        Admission.create(user_id: user.id, chat_room_id: self.id)
    end
    
    # Pusher.trigger
    
    def create_chat_room_notification
        Pusher.trigger('chat_room', 'create', self.as_json)
        # (channer_name, event_name, data)
        # channer의 이름과, 이 channel에서 발생할 event_name, 그리고 이 event에 전달할 data
    end
    
    def user_exit_room(user)
        Admission.where(user_id: user.id, chat_room_id: self.id)[0].destroy
    end
    
    def master_user?(user)
        self.master_id == user.email
    end
    
    def master_update
        self.update(master_id: self.admissions[0].user.email)
        Pusher.trigger("chat_room_#{self.id}",'update',{})
    end
    
end
