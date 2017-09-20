# -*- coding: utf-8 -*-
'''
    Unit message models.
'''

# This file is part of aqueduct.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import uuid
import arrow
from schematics import models
from schematics import types
from schematics.types import compound

class Unit(models.Model):
    '''
        Unit messages
    '''
    uuid = types.UUIDType(default=uuid.uuid4)
    account = types.StringType(required=True)
    name = types.StringType()
    style = types.StringType()
    description = types.StringType()
    payload = types.StringType()
    status = types.StringType()
    region = types.StringType()
    ranking = types.StringType()
    public = types.StringType()
    checksum = types.StringType()
    checked = types.BooleanType(default=False)
    checked_by = types.StringType()
    checked_at = types.TimestampType(default=arrow.utcnow().timestamp)
    last_update_at = types.TimestampType(default=arrow.utcnow().timestamp)
    last_update_by = types.StringType()
    uri = types.StringType()
    labels_set = compound.ListType(types.StringType())
    labels_total = types.IntType()
    history = compound.ListType(types.StringType())
    history_total = types.IntType()
    hashs = compound.ListType(types.StringType())
    hashs_total = types.IntType()

class ModifyUnit(models.Model):
    '''
        Modify Unit

        This model is similar to event.

        It lacks of require and default values on it's fields.

        The reason of it existence is that we need to validate
        every input data that came from outside the system, with
        this we prevent users from using PATCH to create fields
        outside the scope of the resource.
    '''
    uuid = types.UUIDType()
    account = types.StringType()
    name = types.StringType()
    style = types.StringType()
    description = types.StringType()
    payload = types.StringType()
    status = types.StringType()
    region = types.StringType()
    ranking = types.StringType()
    public = types.StringType()
    checksum = types.StringType()
    checked = types.BooleanType()
    checked_by = types.StringType()
    checked_at = types.TimestampType(default=arrow.utcnow().timestamp)
    last_update_at = types.TimestampType(default=arrow.utcnow().timestamp)
    last_update_by = types.StringType()
    uri = types.StringType()
    labels_set = compound.ListType(types.StringType())
    labels_total = types.IntType()
    history = compound.ListType(types.StringType())
    history_total = types.IntType()
    hashs = compound.ListType(types.StringType())
    hashs_total = types.IntType()