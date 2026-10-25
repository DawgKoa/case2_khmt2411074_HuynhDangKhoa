const mongoose = require('mongoose');

const emailLogSchema = new mongoose.Schema(
  {
    taskId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Task',
      default: null,
      index: true,
    },
    recipientEmail: {
      type: String,
      required: [true, 'recipientEmail là bắt buộc'],
      trim: true,
      lowercase: true,
    },
    eventType: {
      type: String,
      required: [true, 'eventType là bắt buộc'],
    },
    subject: {
      type: String,
      required: [true, 'subject là bắt buộc'],
    },
    status: {
      type: String,
      enum: ['pending', 'sent', 'failed'],
      default: 'pending',
      index: true,
    },
    attempts: {
      type: Number,
      default: 1,
    },
    errorMessage: {
      type: String,
      default: null,
    },
    sentAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: true },
  }
);

emailLogSchema.index({ recipientEmail: 1, status: 1 });

module.exports = mongoose.model('EmailLog', emailLogSchema);
