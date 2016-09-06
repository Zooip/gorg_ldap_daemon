#!/usr/bin/env ruby
# encoding: utf-8


require 'yaml'
require 'gorg_service'
require 'active_ldap'

$LOAD_PATH.unshift File.expand_path('..', __FILE__)

class GorgLdapDaemon
  #Initialize running environment and dependencies
  # TODO Allow Logger overriding
  def initialize
    @gorg_service=GorgService.new
  end

  #Run the worker
  # Exit with Ctrl+C
  def run
    begin
      puts " [*] Running #{self.class.config[:application_name]} with pid #{Process.pid}"
      puts " [*] Running in #{self.class.env} environment"
      puts " [*] To exit press CTRL+C or send a SIGINT"
      self.start
      loop do
        sleep(1)
      end
    rescue SystemExit, Interrupt => _
      self.stop
    end
  end

  def start
    GorgLdapDaemon.logger.info("Starting LdapDaemon Bot")
    @gorg_service.start
  end

  def stop
    GorgLdapDaemon.logger.info("Stopping LdapDaemon Bot")
    @gorg_service.stop
  end


  #Class methods
  def self.env
    ENV['GORG_LDAP_DAEMON_ENV'] || "development"
  end

  def self.config
    @config||=GorgLdapDaemon::Configuration.new(self.env)
  end

  def self.root
    File.dirname(__FILE__)
  end

def self.logger
    unless @logger
      STDOUT.sync = true #Allow realtime logging in Heroku
      @logger = Logger.new(STDOUT)

      @logger.level = case (self.config[:logger_level]||"").downcase
      when "debug"
        Logger::DEBUG
      when "info"
        Logger::INFO
      when "warn"
        Logger::WARN
      when "error"
        Logger::ERROR
      when "fatal"
        Logger::FATAL
      when "unknown"
        Logger::UNKNOWN
      else
        Logger::DEBUG
      end
    end
    @logger
  end
end

require 'byebug' unless GorgLdapDaemon.env == "production"
require File.expand_path("../configuration.rb",__FILE__)
require File.expand_path("../message_handlers/base_message_handler.rb",__FILE__)
Dir[File.expand_path("../**/*.rb",__FILE__)].each {|file| require file }
Dir[File.expand_path("../../config/initializers/*.rb",__FILE__)].each {|file|require file }