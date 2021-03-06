# frozen_string_literal: true
#
# Copyright (C) 2018 Harald Sitter <sitter@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) version 3, or any
# later version accepted by the membership of KDE e.V. (or its
# successor approved by the membership of KDE e.V.), which shall
# act as a proxy defined in Section 6 of version 3 of the license.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

require_relative 'openqa_base'

# openqa installation test
class OpenQAInstallJob < OpenQAJobBase
  attr_reader :series
  attr_reader :type
  attr_reader :edition

  def initialize(series:, type:)
    @series = series
    @type = type
    @edition = edition_from_type(type)
    name = "openqa_#{series}_#{edition}_installation"
    name += "_#{suffix}" if suffix
    super(name, job_template: 'openqa_install',
                template: '') # there is no script template, it is in-repo
    return if method(:env).owner == OpenQAInstallJob
    raise "Don't override OpenQAInstallJob#env in #{self.class}, override" \
          ' #extra_env instead!'
  end

  def script_path
    'Jenkinsfile'
  end

  # Override extra_env to add stuff.
  def env
    %w[INSTALLATION=1] + extra_env
  end

  def suffix
    match = self.class.to_s.match(/OpenQAInstall(?<suffix>\w+)Job/)
    return nil unless match
    match[:suffix].downcase
  end

  private

  def extra_env
    # Only the main install job may archive itself.
    return [] unless self.class == OpenQAInstallJob
    # And only iff the it is the currently active series OR selected futures.
    # NB: There are space concerns for archiving right now; hence the
    #   restriction
    if series == NCI.future_series && !%w[release unstable].include?(type)
      return []
    end

    %w[ARCHIVE=1]
  end
end

# openqa secureboot installation test
class OpenQAInstallSecurebootJob < OpenQAInstallJob
  def extra_env
    %w[OPENQA_SECUREBOOT=1]
  end
end

# openqa offline installation test
class OpenQAInstallOfflineJob < OpenQAInstallJob
  def extra_env
    %w[OPENQA_INSTALLATION_OFFLINE=1]
  end
end

# openqa bios installation test
class OpenQAInstallBIOSJob < OpenQAInstallJob
  def extra_env
    %w[OPENQA_BIOS=1]
  end
end

# openqa oem installation test
class OpenQAInstallOEMJob < OpenQAInstallJob
  def extra_env
    %w[INSTALLATION_OEM=1]
  end
end

# openqa nonenglish installation test
class OpenQAInstallNonEnglishJob < OpenQAInstallJob
  def extra_env
    %w[OPENQA_INSTALLATION_NONENGLISH=1]
  end
end

# Runs all partitioning scenarios to make sure kpmcore isn't blowing up.
class OpenQAInstallPartitioningJob < OpenQAInstallJob
  def extra_env
    %w[OPENQA_PARTITIONING=1]
  end
end
