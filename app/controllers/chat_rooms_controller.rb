class ChatRoomsController < ApplicationController
  before_action :set_chat_room, only: [:show, :edit, :update, :destroy, :user_admit_room, :chat, :user_exit_room]
  before_action :authenticate_user!, except: [:index]
  # GET /chat_rooms
  # GET /chat_rooms.json
  def index
    @chat_rooms = ChatRoom.all
  end

  # GET /chat_rooms/1
  # GET /chat_rooms/1.json
  def show
  end

  # GET /chat_rooms/new
  def new
    @chat_room = ChatRoom.new
  end

  # GET /chat_rooms/1/edit
  def edit
  end

  # POST /chat_rooms
  # POST /chat_rooms.json
  def create
    @chat_room = ChatRoom.new(chat_room_params)
    @chat_room.master_id = current_user.email
    respond_to do |format|
      if @chat_room.save
        
        @chat_room.user_admit_room(current_user) # Admission create method
        
        format.html { redirect_to @chat_room, notice: 'Chat room was successfully created.' }
        format.json { render :show, status: :created, location: @chat_room }
      else
        format.html { render :new }
        format.json { render json: @chat_room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chat_rooms/1
  # PATCH/PUT /chat_rooms/1.json
  def update
    respond_to do |format|
      if @chat_room.update(chat_room_params)
        format.html { redirect_to @chat_room, notice: 'Chat room was successfully updated.' }
        format.json { render :show, status: :ok, location: @chat_room }
      else
        format.html { render :edit }
        format.json { render json: @chat_room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chat_rooms/1
  # DELETE /chat_rooms/1.json
  def destroy
    if @chat_room.master_user?(current_user)
      @chat_room.destroy
    else
      render js: ""
    end
  end
  
  def user_admit_room #room에 join하는 method
    # 현재 유저가 있는 방에서 join버튼을 눌렀을 때, 동작하는 액션
    if current_user.joined_room?(@chat_room)
      # 유저가 참가하고 있는 방의 목록 중에 이 방이 포함되어 있나?
      # 방에 참가하고 있는 유저들 중에 이 유저가 포함되어 있나?
      #current_user.chat_rooms.where(id: params[:id])[0].nil?
      
      render js: "alert('이미 참여중인 방입니다.')"
    else
      @chat_room.user_admit_room(current_user)
    end
    
  end
  
  def chat
    @chat_room.chats.create(user_id: current_user.id, message: params[:message])
  end
  
  def user_exit_room
    #방 나가고 인원수가 0이면
    if @chat_room.admissions.size <= 1
      @chat_room.destroy
    else #방 나가고 인원수가 1 이상인데
      @chat_room.user_exit_room(current_user)
      if @chat_room.master_user?(current_user) #방 나간 사람이 방장이면
        puts "방장 승계 중입니다."
        @chat_room.master_update#방장을 넘긴다.
      end
    end
    
    
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat_room
      @chat_room = ChatRoom.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chat_room_params
      params.fetch(:chat_room, {}).permit(:title, :max_count)
    end
end
