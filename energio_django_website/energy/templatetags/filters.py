from django.template.defaulttags import register

@register.filter(name='one_more')
def one_more(_1, _2):
    return _1, _2

@register.filter(name='get_item_from_tuple')
def get_item_from_tuple(_1_2, _3):
    _1, _2 = _1_2
    return _1.get((_2, _3))

@register.filter(name='get_item_from_dict')
def get_item_from_dict(_1, _2):
    return _1.get(_2)

@register.filter(name='to_date')
def to_date(date):
    return date.strftime("%Y-%m-%d %H:%M")


@register.filter(name='get_tuple')
def get_tuple(tuple, index):
    return tuple[index]