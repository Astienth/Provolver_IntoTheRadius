using Microsoft.WindowsAPICodePack.Dialogs;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using Provolver_IntoTheRadius.Properties;

namespace Provolver_IntoTheRadius
{
    public class Form1 : Form
    {
        public Engine engine;
        private IContainer components;
        private PictureBox pictureBox1;
        private Button btnStart;
        private Label lblInfo;
        private Label label2;

        public Form1() => this.InitializeComponent();

        private void WriteTextSafe(string text)
        {
            if (this.lblInfo.InvokeRequired)
                this.lblInfo.Invoke((Delegate)new Form1.SafeCallDelegate(this.WriteTextSafe), (object)text);
            else
                this.lblInfo.Text = "Status: " + text;
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            this.btnStart.Enabled = false;
            this.engine = new Engine();
            this.engine.initEngine();
            this.WriteTextSafe("Initializing Provolver and starting...");
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.btnStart.Enabled = true;
            this.WriteTextSafe("Stopping...");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing && this.components != null)
                this.components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            ComponentResourceManager componentResourceManager = new ComponentResourceManager(typeof(Form1));
            this.pictureBox1 = new PictureBox();
            this.btnStart = new Button();
            this.lblInfo = new Label();
            this.label2 = new Label();
            ((ISupportInitialize)this.pictureBox1).BeginInit();
            this.SuspendLayout();
            this.pictureBox1.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            this.pictureBox1.Image = Resources.logoITR;
            this.pictureBox1.Location = new Point(60, 25);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new Size(360, 220);
            this.pictureBox1.TabIndex = 0;
            this.pictureBox1.TabStop = false;
            this.pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage;
            this.btnStart.Font = new Font("Microsoft Sans Serif", 20f, FontStyle.Regular, GraphicsUnit.Point, (byte)0);
            this.btnStart.Location = new Point(135, 260);
            this.btnStart.Name = "btnStart";
            this.btnStart.Size = new Size(188, 61);
            this.btnStart.TabIndex = 1;
            this.btnStart.Text = "Start";
            this.btnStart.UseVisualStyleBackColor = true;
            this.btnStart.Click += new EventHandler(this.btnStart_Click);
            this.lblInfo.AutoSize = true;
            this.lblInfo.Font = new Font("Microsoft Sans Serif", 12f, FontStyle.Regular, GraphicsUnit.Point, (byte)0);
            this.lblInfo.Location = new Point(25, 335);
            this.lblInfo.Name = "lblInfo";
            this.lblInfo.Size = new Size(74, 20);
            this.lblInfo.TabIndex = 3;
            this.lblInfo.Text = "Status: Waiting...";
            this.lblInfo.ForeColor = System.Drawing.Color.White;
            this.AutoScaleDimensions = new SizeF(8f, 18f);
            this.AutoScaleMode = AutoScaleMode.Font;
            this.AutoSizeMode = AutoSizeMode.GrowAndShrink;
            this.BackColor = Color.Black;
            this.ClientSize = new Size(463, 373);
            this.Controls.Add((Control)this.label2);
            this.Controls.Add((Control)this.lblInfo);
            this.Controls.Add((Control)this.btnStart);
            this.Controls.Add((Control)this.pictureBox1);
            this.Icon = Resources.favicon;
            this.MaximumSize = new Size(479, 412);
            this.MinimumSize = new Size(479, 412);
            this.Name = nameof(Form1);
            this.Text = "Provolver Into The Radius";
            this.FormClosing += new FormClosingEventHandler(this.Form1_FormClosing);
            ((ISupportInitialize)this.pictureBox1).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();
        }

        private delegate void SafeCallDelegate(string text);
    }
}
