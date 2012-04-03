<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
        <?= $this->Html->charset(); ?>
        <title>
            Wingolf
            <?php
            /*
              __('Wingolf');
              echo Sanitize::html($title_for_layout);
             */
            ?>
        </title>
        <?php
        echo $this->Html->meta('icon');
        echo $this->Html->meta('icon');
        echo $this->Html->meta('description', '');
        echo $this->Html->meta('keywords', '');
        echo $this->Html->css('jquery.fancybox-1.3.4');
        echo $this->Html->css('jquery-ui-1.8.16.custom');
        echo $this->Html->css('datatables/jquery.dataTables_themeroller');
        echo $this->Html->css('global');
        echo $this->Html->css('backend');
        echo '
            <script type="text/javascript">
                var webroot = "' . Configure::read('App.base') . '";
            </script>
        ';
        echo $this->Html->script('jquery-1.7.1.min');
        echo $this->Html->script('jquery-ui-1.8.16.custom.min');
        echo $this->Html->script('jquery.fancybox-1.3.4.pack');
        echo $this->Html->script('jquery.validate.min');
        echo $this->Html->script('jquery.validate.localization_de');
        echo $this->Html->script('global');
        echo $this->Html->script('backend');
        echo $this->Html->script('jquery.hotkeys');
        echo $this->Html->script('jquery.slidingmessage.min');
        echo $this->Html->script('jquery.tools.min');
        echo $this->Html->script('messages_de');
        echo $this->Html->script('jquery.form');
        echo $this->Html->script('universities');
        echo $this->Html->script('datatables/jquery.dataTables.min');
        echo $scripts_for_layout;
        ?>

    </head>
    <body>
        <span class="tooltip">&nbsp;</span>
        <div id="dialog-confirm" style="display: none;">
        </div>
        <div id="backendBar">
            <div id="backendBar_content">
                <div id="backendBar_content_profile">
                    <?php
                    echo $this->Html->link($this->Html->image($Authuser['User']['avatar']['s'], array('alt' => h($Authuser['User']['screenname']))), $Authuser['User']['profile_url'], array('title' => h($Authuser['User']['screenname']), 'escape' => false));
                    echo $this->Html->link($Authuser['User']['screenname'], $Authuser['User']['profile_url'], array('title' => '', 'class' => 'text'));
                    ?>
                </div>
                <div id="backendBar_content_navi">
                    <ul>
                        <li class="active"><?= $this->Html->link('Mein Profil', $Authuser['User']['profile_url'], array('title' => 'Profil anzeigen')); ?></li>
                        <?= $this->element('General/dropdown_groups'); ?>

                        <?php
                        if (!empty($admin_menu_groups) || !empty($Authuser['permissions']['groups']['edit']) || !empty($user_is_superadmin)) {
                            echo $this->element('General/dropdown_mitglieder');
                        }
                        ?>

                    </ul>
                    <div class="clear"></div>
                </div>
                <div id="backendBar_content_logout"><?= $this->Html->link('Abmelden', array('controller' => 'users', 'action' => 'logout'), array('title' => '')); ?></div>
                <div class="clear"></div>
            </div>
        </div>
        <div id="headerBg">
            <div id="header">
                <div id="header_claim">
                    <?php
                    echo $this->Html->link($this->Html->image('claim.png', array('alt' => 'Wingolf – christliche, farbentragende, nichtschlagende Studentenverbindung', 'title' => 'Wingolf – christliche, farbentragende, nichtschlagende Studentenverbindung')), Router::url('/', true), array('title' => 'Wingolf - Christlich Farbentragend Nichtschlagend', 'escape' => false));
                    ?>
                </div>
                <div id="header_logo">
                    <?php
                    echo $this->Html->link($this->Html->image('logo.png', array('alt' => 'Wingolf – christliche, farbentragende, nichtschlagende Studentenverbindung', 'title' => 'Wingolf – christliche, farbentragende, nichtschlagende Studentenverbindung')), Router::url('/', true), array('title' => 'Wingolf - Christlich Farbentragend Nichtschlagend', 'escape' => false));
                    ?>
                </div>
                <div id="header_search">
                    <?php
                    echo $this->Form->create('Search', array('url' => array('controller' => 'searches', 'action' => 'index')));

                    $searchDefault = 'Mitglied, Inhalt ...';
                    echo $this->Form->input('q', array(
                        'label' => false,
                        'id' => 'header_search_input',
                        'default' => $searchDefault,
                        'onfocus' => 'if(this.value == "' . $searchDefault . '") this.value = ""',
                        'onblur' => 'if(this.value == "") this.value = "' . $searchDefault . '"'
                    ));

                    echo $this->Form->submit('search_button.png', array(
                        'id' => 'search_button'
                    ));

                    echo '<div class="clear"></div>';

                    echo $this->Form->end();
                    ?>
                    <?php /* <div id="header_search_extented">
                      <?= $this->Html->link('Erweiterte Suche &raquo;', '#', array('escape' => false, 'title' => '')); ?>
                      </div> */ ?>
                </div>
                <div id="header_navi">
                    <?= $this->element('General/navi_horizontal') ?>
                </div>
            </div>
        </div>

        <div id="contentBgLayer1">
            <div id="contentBgLayer2">
                <div id="contentBgLayer3">
                    <div id="content_wrapper">
                        <div id="breadcrumb">
                            <?= $this->Page->breadcrumb($path, $active_page); ?>

                            <div class="clear"></div>
                        </div>

                        <div id="content">
                            <?php
                            if (!empty($Authuser['permissions']['pages']['edit'])):
                                ?>
                                <div id="start_edit">
                                    <a href="javascript:void(0);" onclick="startEditMode();">Bearbeiten aus</a>
                                </div>
                                <?php
                            endif;
                            ?>
                            <div class="content_twoCols content_twoCols-20-80">
                                <div class="content_twoCols_left">
                                    <?php
                                    $this->Page->pages_navi($active_page, $path, $children, $neighbors, $this->layout, $Authuser['permissions'], $page_role);

                                    if (!empty($Authuser['Groups'])) {
                                        //$this->Page->groups_navi($Authuser['Groups']);
                                    }
                                    ?>
                                </div>

                                <div class="content_twoCols_right">
                                    <?= $this->Session->flash('redirect'); ?>
                                    <?= $content_for_layout; ?>
                                </div>
                                &nbsp;
                                <div class="clear"></div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <div id="footer">
            <div id="footer_bg"></div>
            <div id="footer_navi">
                <ul>
                    <li><?= $this->Html->link('Hilfe/Hinweise', '#', array('title' => '')); ?></li>
                    <li><?= $this->Html->link('Verbesserungen', '#', array('title' => '')); ?></li>
                    <li><?= $this->Html->link('Ansprechpartner', '#', array('title' => '')); ?></li>
                    <li><?= $this->Html->link('Impressum', '#', array('title' => '')); ?></li>
                </ul>
                <div class="clear"></div>
            </div>
            <div id="footer_line"></div>
        </div>
        <?= $this->element('sql_dump'); ?>
    </body>
</html>