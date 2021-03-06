class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :require_participant, only: [:show]
  before_action :require_author, only: [:edit, :update, :destroy]

  def index
    @groups = Group.includes(:joins).limit(50)
  end

  def show
    @group_tasks = @group.has_tasks.slice(0, 50)
    @read_task_ids = current_user.reads.pluck(:task_id)
  end

  def new
    @group = Group.new
  end

  def edit; end

  def create
    @group = current_user.groups.build(group_params)

    if @group.save
      Join.create!(user_id: current_user.id, group_id: @group.id)
      redirect_to @group, notice: t("layout.group.notice_create")
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: t("layout.group.notice_update")
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: t("layout.group.notice_destroy")
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def require_participant
    redirect_to groups_path if Join.to_match(current_user, @group).blank?
  end

  def require_author
    redirect_to groups_path unless @group.user_id == current_user.id
  end

  def group_params
    params.require(:group).permit(:name, :description)
  end
end
