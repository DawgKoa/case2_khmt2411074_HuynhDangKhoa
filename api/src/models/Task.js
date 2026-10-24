const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Tên công việc là bắt buộc'],
      trim: true,
      maxlength: [200, 'Tên công việc không được vượt quá 200 ký tự'],
    },
    description: {
      type: String,
      default: '',
      trim: true,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    assigneeIds: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    primaryAssigneeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    // Chia sẻ công việc và phân quyền RBAC (C3)
    sharedWith: [
      {
        userId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User',
          required: true,
        },
        role: {
          type: String,
          enum: ['viewer', 'editor', 'admin'],
          default: 'viewer',
        },
        sharedAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],
    startDate: {
      type: Date,
      default: null,
    },
    dueDate: {
      type: Date,
      default: null,
    },
    priority: {
      type: String,
      enum: {
        values: ['low', 'medium', 'high'],
        message: 'Mức độ ưu tiên phải là low, medium hoặc high',
      },
      default: 'medium',
    },
    status: {
      type: String,
      enum: {
        values: ['todo', 'in_progress', 'completed', 'cancelled'],
        message: 'Trạng thái phải là todo, in_progress, completed hoặc cancelled',
      },
      default: 'todo',
    },
  },
  {
    timestamps: true,
  }
);

// Indexes phục vụ tìm kiếm và sắp xếp hiệu quả
taskSchema.index({ createdBy: 1, status: 1, priority: 1, dueDate: 1 });
taskSchema.index({ assigneeIds: 1 });
taskSchema.index({ 'sharedWith.userId': 1 });
taskSchema.index({ title: 'text', description: 'text' });

module.exports = mongoose.model('Task', taskSchema);
