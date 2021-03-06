{extend name="base/common"}
{block name="body"}
    <div class="container-fluid" id="config-app">
        <div class="row data-list-header-action">
        </div>
        <div class="row">
            <!--增加modal-->
            <div class="modal fade" id="addEditModel" tabindex="-1" role="dialog"
                 aria-labelledby="myLargeModalLabel">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                                        aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title" v-html="tmp_model.modal_title"></h4>
                        </div>
                        <div class="modal-body">
                            <form action="{:url('bbs.post/addEdit')}" method="post">
                                <input type="hidden" name="id" v-model="tmp_model.id">
                                <div class="form-group">
                                    <label for="" class="control-label">标题</label>
                                    <input type="text" name="title" class="form-control disabled" readonly
                                           placeholder="请输入标题"
                                           v-model="tmp_model.title">
                                </div>
                                <div class="form-group">
                                    <label for="" class="control-label">所属栏目</label>
                                    <select class="form-control" name="category_id" id=""
                                            v-model="tmp_model.category_id">
                                        <option value="" v-for="cate in category" :value="cate.id"
                                                v-html="cate.title"></option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="" class="control-label">排序(小号在前)</label>
                                    <input type="number" name="sort" class="form-control" v-model="tmp_model.sort">
                                </div>
                                <div class="form-group">
                                    <label for="" class="control-label">备注</label>
                                    <textarea name="mark" class="form-control" v-model="tmp_model.mark"></textarea>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                            <button type="button" class="btn btn-primary" v-on:click="sureAddEdit">确认</button>
                        </div>
                    </div>
                </div>
            </div>
            <table class="table-bordered table table-responsive table-hover text-center">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>父ID</th>
                    <th style="width:200px;" class="online-title">帖子标题</th>
                    <th>回帖用户</th>
                    <th>回帖时间</th>
                    <th>状态</th>
                    <th style="width: 10%">操作</th>
                </tr>
                </thead>
                <tbody>
                <tr v-for="vo in data_list">
                    <td><span v-html="vo.id" :id="'comment-'+vo.id"></span></td>
                    <td><a v-html="vo.pid" :href="'#comment-'+vo.id" class="cursor-pointer"></a></td>
                    <td>
                        <span style="width:200px;" class="online-title" v-if="vo.post" v-html="vo.post.title"></span>
                        <span class="text-danger" v-else="vo.post">已删除</span>
                    </td>
                    <td><span v-if="vo.user" v-html="vo.user.nickname"></span><span class="text-danger" v-if="!vo.user">已删除</span>
                    </td>
                    <td><span v-html="vo.create_time"></span></td>
                    <td><label class="label cursor-pointer"
                               :class="vo.status===1?'label-success':'label-danger'"
                               v-on:click="changeStatus(vo)"
                               v-html="vo.status===1?'已审核':'未审核'"></label></td>
                    <td>
                        <button type="button" class="btn btn-sm btn-danger" v-on:click="del(vo.id)">删除
                        </button>
                    </td>
                </tr>
                </tbody>
            </table>
            <div class="pager">
                <paginate
                        :page-count="pagination.last_page"
                        :click-handler="loadData"
                        :prev-text="'上一页'"
                        :next-text="'下一页'"
                        :container-class="'pagination'">
                </paginate>
            </div>
        </div>
    </div>
    <script>

        require(['vue', 'layer', 'vuePager'], function (Vue, layer, vuePager) {
            Vue.component('paginate', vuePager);
            var app = new Vue({
                el: "#config-app",
                data: {
                    data_list: [],
                    tmp_model: {
                        method: 'add',
                        modal_title: "新增",
                        //model
                        id: null,
                        title: '',
                        sort: 0,
                        mark: ''
                    },
                    category: [],
                    pagination: {
                        current_page: 0,
                        last_page: 0,
                        per_page: 0,
                        total: 0
                    }
                },
                methods: {
                    loadData: function (pageNum) {
                        var self = this;
                        if (pageNum) {
                            this.pagination.current_page = pageNum;
                        } else {
                            pageNum = this.pagination.current_page;
                        }
                        self.data_list = [];
                        $.post("{:url('bbs.comment/getList')}",{page:pageNum}, function (ret) {
                            ret.data.data_list.data.forEach(function (item) {
                                item.checked = false;
                                self.data_list.push(item);
                            });
                            //分页
                            self.pagination.current_page = ret.data.data_list.current_page;
                            self.pagination.last_page = ret.data.data_list.last_page;
                            self.pagination.per_page = ret.data.data_list.per_page;
                            self.pagination.total = ret.data.data_list.total;
                        });
                    },
                    edit: function (vo) {
                        //写入模型
                        this.tmp_model = vo;
                        this.tmp_model.modal_title = "编辑";
                        this.tmp_model.method = "edit";
                        $('#addEditModel').modal('toggle');
                    },
                    del: function (id) {
                        var self = this;
                        layer.confirm("确认删除么(不可恢复)",{}, function () {
                            $.post("{:url('bbs.comment/del')}",{id:id}, function (ret) {
                                layer.msg(ret.msg);
                                self.loadData();
                            });
                        }, function () {
                            layer.msg("用户删除取消");
                        })
                    },
                    delMore: function () {

                    },
                    changeStatus: function (vo) {
                        var self = this;
                        $.post("{:url('bbs.comment/changeStatus')}",{id:vo.id}, function (ret) {
                            if (ret.code === 1) {
                                vo.status = vo.status === 1 ? 0 : 1;
                            }
                        });
                    },
                    sureAddEdit: function () {
                        var self = this;
                        //保存
                        $.post("{:url('bbs.comment/addEdit')}", self.tmp_model, function (ret) {
                            $('#addEditModel').modal('toggle');
                            self.loadData();
                            layer.msg(ret.msg);
                        });
                    }
                },
                mounted: function () {
                    this.loadData();
                }
            })

        });
    </script>
{/block}